module Summation
export sum_naive, sum_kbn, sum_oro, sum_mixed
export dot_naive, dot_oro, dot_mixed

import VectorizationBase

using VectorizationBase: Vec, vload, vsum, vzero, AbstractSIMD, MM
fptype(::Type{V}) where {W, T, V <: AbstractSIMD{W, T}} = T
@inline f64(x::Number)     = convert(Float64, x)


using ..EFT: two_sum, fast_two_sum, two_prod

include("accumulators/sum.jl")
include("accumulators/dot.jl")
include("accumulators/compSum.jl")
include("accumulators/compDot.jl")
include("accumulators/mixedSum.jl")
include("accumulators/mixedDot.jl")


# T. Ogita, S. Rump and S. Oishi, "Accurate sum and dot product",
# SIAM Journal on Scientific Computing, 6(26), 2005.
# DOI: 10.1137/030601818
@generated function accumulate(x::NTuple{A, AbstractArray{T}},
                               accType::F,
                               rem_handling = Val(:scalar),
                               ::Val{Ushift} = Val(2),
                               ::Val{Prefetch} = Val(0),
                               )  where {F, A, T <: Union{Float32,Float64}, Ushift, Prefetch}
    @assert 0 ≤ Ushift < 6
    U = 1 << Ushift

    W, shift = VectorizationBase.pick_vector_width_shift(T)
    WU = W * U
    V = Vec{W,T}

    quote
        $(Expr(:meta,:inline))
        px = VectorizationBase.zstridedpointer.(x)
        N = length(first(x))
        Base.Cartesian.@nexprs $U u -> begin
            acc_u = accType($V)
        end

        Nshift = N >> $(shift + Ushift)
        offset = MM{$W}(0)
        for n in 1:Nshift
            if $Prefetch > 0
                # VectorizationBase.prefetch.(px.+offset.+$(Prefetch*WT), Val(3), Val(0))
                VectorizationBase.prefetch0.(px, offset + $(Prefetch*W))
            end

            Base.Cartesian.@nexprs $U u -> begin
                xi = vload.(px, tuple(tuple(MM{$W}(offset)))) # vload expects the index to be wrapped in a tuple, and broadcasting strips one layer
                add!(acc_u, xi...)
                offset += $W
            end
        end

        rem = N & $(WU-1)
        for n in 1:(rem >> $shift)
            xi = vload.(px, tuple(tuple(MM{$W}(offset))))
            add!(acc_1, xi...)
            offset += $W
        end

        if $rem_handling <: Val{:mask}
            rem &= $(W-1)
            if rem > 0
                mask = VectorizationBase.mask(Val{$W}(), rem)
                xi = vload.(px, tuple(tuple(MM{$W}(offset))), mask)
                add!(acc_1, xi...)
            end
        end

        Base.Cartesian.@nexprs $(U-1) u -> begin
            add!(acc_1, acc_{u+1})
        end

        acc = sum(acc_1)

        if $rem_handling <: Val{:scalar}
            _offset = offset.i
            while _offset < N
                @inbounds xi = getindex.(x, (_offset += 1))
                add!(acc, xi...)
            end
        end

        sum(acc)
    end
end

# Default values for unrolling
@inline default_ushift(::SumAcc)      = Val(3)
@inline default_ushift(::CompSumAcc)  = Val(2)
@inline default_ushift(::MixedSumAcc) = Val(3)
@inline default_ushift(::DotAcc)      = Val(3)
@inline default_ushift(::CompDotAcc)  = Val(2)
@inline default_ushift(::MixedDotAcc) = Val(3)
# dispatch
#   either default_ushift(x,    acc)
#   or     default_ushift((x,), acc)
@inline default_ushift(x::AbstractArray, acc) = default_ushift(acc(eltype(x)))
@inline default_ushift(x::NTuple, acc)        = default_ushift(first(x), acc)


# Default values for cache prefetching
@inline default_prefetch(::SumAcc)      = Val(0)
@inline default_prefetch(::CompSumAcc)  = Val(35)
@inline default_prefetch(::MixedSumAcc) = Val(0)
@inline default_prefetch(::DotAcc)      = Val(0)
@inline default_prefetch(::CompDotAcc)  = Val(20)
@inline default_prefetch(::MixedDotAcc) = Val(0)
# dispatch
#   either default_prefetch(x,    acc)
#   or     default_prefetch((x,), acc)
@inline default_prefetch(x::AbstractArray, acc) = default_prefetch(acc(eltype(x)))
@inline default_prefetch(x::NTuple, acc)        = default_prefetch(first(x), acc)


@inline _sum(x, acc) = if length(x) < 500
    # no cache prefetching for small vectors
    accumulate((x,), acc, Val(:scalar), default_ushift(x, acc), Val(0))
else
    accumulate((x,), acc, Val(:scalar), default_ushift(x, acc), default_prefetch(x, acc))
end

sum_naive(x) = _sum(x, sumAcc)
sum_kbn(x)   = _sum(x, compSumAcc(fast_two_sum))
sum_oro(x)   = _sum(x, compSumAcc(two_sum))
sum_mixed(x) = _sum(x, mixedSumAcc)


@inline _dot(x, y, acc) = if length(x) < 500
    # no cache prefetching for small vectors
    accumulate((x,y), acc, Val(:scalar), default_ushift(x, acc), Val(0))
else
    accumulate((x,y), acc, Val(:scalar), default_ushift(x, acc), default_prefetch(x, acc))
end

dot_naive(x, y) = _dot(x, y, dotAcc)
dot_oro(x, y)   = _dot(x, y, compDotAcc)
dot_mixed(x, y) = _dot(x, y, mixedDotAcc)

end
