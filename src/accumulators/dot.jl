mutable struct DotAcc{T}
    s :: T
end

dotAcc(T) = DotAcc{T}(vzero(T))

function add!(acc::DotAcc, x, y)
    @fastmath acc.s += x * y
end

function add!(acc::DotAcc{T}, x::DotAcc{T}) where {T}
    @fastmath acc.s += x.s
end

Base.sum(acc::DotAcc{T}) where {T<:Vec}  = DotAcc(vsum(acc.s))
Base.sum(acc::DotAcc{T}) where {T<:Real} = acc.s
