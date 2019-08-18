module Summation
export sum_naive, sum_kbn, sum_oro
export dot_naive, dot_oro

import VectorizationBase

import ..SIMDops
using  ..SIMDops: Vec, vload, vsum, vzero, fptype

using ..EFT: two_sum, fast_two_sum, two_prod

include("accumulators/sum.jl")
include("accumulators/dot.jl")
include("accumulators/compSum.jl")
include("accumulators/compDot.jl")


# T. Ogita, S. Rump and S. Oishi, "Accurate sum and dot product",
# SIAM Journal on Scientific Computing, 6(26), 2005.
# DOI: 10.1137/030601818
@generated function accumulate(x::NTuple{A, AbstractArray{T}},
                                 accType::F,
                                 rem_handling = Val(:scalar),
                                 ::Val{Ushift} = Val(2)
                                 )  where {F, A, T <: Union{Float32,Float64}, Ushift}
    @assert 0 ≤ Ushift < 6
    U = 1 << Ushift

    W, shift = VectorizationBase.pick_vector_width_shift(T)
    sizeT = sizeof(T)
    WT = W * sizeT
    WU = W * U
    V = Vec{W,T}

    quote
        $(Expr(:meta,:inline))
        px = pointer.(x)
        N = length(first(x))
        Base.Cartesian.@nexprs $U u -> begin
            acc_u = accType($V)
        end

        Nshift = N >> $(shift + Ushift)
        offset = 0
        for n in 1:Nshift
            Base.Cartesian.@nexprs $U u -> begin
                xi = vload.($V, px.+offset)
                add!(acc_u, xi...)
                offset += $WT
            end
        end

        rem = N & $(WU-1)
        for n in 1:(rem >> $shift)
            xi = vload.($V, px.+offset)
            add!(acc_1, xi...)
            offset += $WT
        end

        if $rem_handling <: Val{:mask}
            rem &= $(W-1)
            if rem > 0
                mask = VectorizationBase.mask(Val{$W}(), rem)
                xi = vload.($V, px.+offset, mask)
                add!(acc_1, xi...)
            end
        end

        Base.Cartesian.@nexprs $(U-1) u -> begin
            add!(acc_1, acc_{u+1})
        end

        acc = sum(acc_1)

        if $rem_handling <: Val{:scalar}
            offset = div(offset, $sizeT) + 1
            while offset <= N
                @inbounds xi = getindex.(x, offset)
                add!(acc, xi...)
                offset += 1
            end
        end

        sum(acc)
    end
end

sum_naive(x) = accumulate((x,), sumAcc,                   Val(:scalar), Val(3))
sum_kbn(x)   = accumulate((x,), compSumAcc(fast_two_sum), Val(:scalar), Val(2))
sum_oro(x)   = accumulate((x,), compSumAcc(two_sum),      Val(:scalar), Val(2))

dot_naive(x, y) = accumulate((x,y), dotAcc,     Val(:scalar), Val(3))
dot_oro(x, y)   = accumulate((x,y), compDotAcc, Val(:scalar), Val(2))

end
