mutable struct SumAcc{T}
    s :: T
end

sumAcc(T) = SumAcc(vzero(T))

function add!(acc::SumAcc, x)
    @fastmath acc.s += x
end

function add!(acc::SumAcc{T}, x::SumAcc{T}) where {T}
    @fastmath acc.s += x.s
end

Base.sum(acc::SumAcc{T}) where {T<:Vec}  = SumAcc(vsum(acc.s))
Base.sum(acc::SumAcc{T}) where {T<:Real} = acc.s
