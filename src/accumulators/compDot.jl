mutable struct CompDotAcc{T}
    s :: T
    e :: T
end

compDotAcc(T) = CompDotAcc{T}(vzero(T), vzero(T))

@inline function add!(acc::CompDotAcc{T}, x::T, y::T) where {T}
    p, ep = two_prod(x, y)
    acc.s, es = two_sum(acc.s, p)

    @fastmath acc.e += ep + es
end

@inline function add!(acc::A, x::A) where {A<:CompDotAcc}
    acc.s, e = two_sum(acc.s, x.s)

    @fastmath acc.e += x.e + e
end

@inline function Base.sum(acc::CompDotAcc{T}) where {W, T<:Vec{W}}
    acc_r = compDotAcc(fptype(T))
    acc_r.e = vsum(acc.e)
    for w in 1:W
        acc_r.s, ei = two_sum(acc_r.s, acc.s(w))
        acc_r.e += ei
    end        
    acc_r
end

@inline function Base.sum(acc::CompDotAcc{T}) where {T<:Real}
    acc.s + acc.e
end
