export Accumulator
mutable struct Accumulator{T, EFT}
    s   :: T
    e   :: T
end

Base.zero(::Type{Vec{W, T}}) where {W, T} = vbroadcast(Vec{W, T}, 0)

eft(acc::Accumulator{T, EFT}) where {T, EFT} = EFT
Base.eltype(acc::Accumulator{T, EFT}) where {T, EFT} = T
fptype(::Type{Vec{W, T}}) where {W, T} = T

Accumulator(T, EFT) = Accumulator{T, EFT}(zero(T), zero(T))

function add!(acc::Accumulator{T, EFT}, x::T) where {T, EFT}
    Pirate.@explicit

    acc.s, e = EFT(acc.s, x)
    acc.e += e
end

function add!(acc::A, x::A) where {A<:Accumulator}
    Pirate.@explicit

    acc.s, e = eft(acc)(acc.s, x.s)
    acc.e += x.e + e
end

function Base.sum(acc::Accumulator{T, EFT}) where {T<:Vec, EFT}
    acc_r = Accumulator(fptype(T), EFT)
    acc_r.e = vsum(acc.e)
    for xi in acc.s
        acc_r.s, ei = EFT(acc_r.s, xi.value)
        acc_r.e += ei
    end
    acc_r
end

function Base.sum(acc::Accumulator{T, EFT}) where {T<:Real, EFT}
    acc.s + acc.e
end




# T. Ogita, S. Rump and S. Oishi, "Accurate sum and dot product",
# SIAM Journal on Scientific Computing, 6(26), 2005.
# DOI: 10.1137/030601818
@generated function cascaded_eft(x::AbstractArray{T},
                                 eft,
                                 rem_handling = Val{:scalar},
                                 ::Val{Ushift} = Val{2}()
                                 )  where {T <: Union{Float32,Float64}, Ushift}
    @assert 0 ≤ Ushift < 6
    U = 1 << Ushift

    W, shift = VectorizationBase.pick_vector_width_shift(T)
    sizeT = sizeof(T)
    WT = W * sizeT
    WU = W * U
    V = Vec{W,T}

    q = quote
        px = pointer(x)
        N = length(x)
        Base.Cartesian.@nexprs $U u -> begin
            acc_u = Accumulator($V, eft)
        end

        Nshift = N >> $(shift + Ushift)
        offset = 0
        for n in 1:Nshift
            Base.Cartesian.@nexprs $U u -> begin
                xi = vload($V, px + offset)
                add!(acc_u, xi)
                offset += $WT
            end
        end

        rem = N & $(WU-1)
        for n in 1:(rem >> $shift)
            xi = vload($V, px + offset)
            add!(acc_1, xi)
            offset += $WT
        end
    end

    if rem_handling <: Val{:mask}
        q_rem = quote
            rem &= $(W-1)
            if rem > 0
                mask = VectorizationBase.mask(Val{$W}(), rem)
                xi = vload($V, px + offset, mask)
                add!(acc_1, xi)
            end
        end
        push!(q.args, q_rem)
    end

    q_reduce = quote
        Base.Cartesian.@nexprs $(U-1) u -> begin
            add!(acc_1, acc_{u+1})
        end

        acc = sum(acc_1)
    end
    push!(q.args, q_reduce)

    if rem_handling <: Val{:scalar}
        q_rem = quote
            offset = div(offset, $sizeT) + 1
            while offset <= N
                @inbounds xi = x[offset]
                add!(acc, xi)
                offset += 1
            end
        end
        push!(q.args, q_rem)
    end

    push!(q.args, :(sum(acc)))

    q
end

sum_kbn(x) = cascaded_eft(x, fast_two_sum, Val(:mask), Val(2))
sum_oro(x) = cascaded_eft(x, two_sum, Val(:mask), Val(2))
