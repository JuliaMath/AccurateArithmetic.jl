mutable struct CompDotAcc{T}
    s :: T
    e :: T
end

compDotAcc(T) = CompDotAcc{T}(zero(T), zero(T))

function add!(acc::CompDotAcc{T}, x::T, y::T) where {T}
    Pirate.@explicit

    p, ep = two_prod(x, y)
    acc.s, es = two_sum(acc.s, p)
    acc.e += ep + es
end

function add!(acc::A, x::A) where {A<:CompDotAcc}
    Pirate.@explicit

    acc.s, e = two_sum(acc.s, x.s)
    acc.e += x.e + e
end

function Base.sum(acc::CompDotAcc{T}) where {T<:Vec}
    acc_r = compDotAcc(fptype(T))
    acc_r.e = vsum(acc.e)
    for xi in acc.s
        acc_r.s, ei = two_sum(acc_r.s, xi.value)
        acc_r.e += ei
    end
    acc_r
end

function Base.sum(acc::CompDotAcc{T}) where {T<:Real}
    acc.s + acc.e
end
