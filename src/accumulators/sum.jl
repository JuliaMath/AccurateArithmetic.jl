mutable struct SumAcc{T}
    s :: T
end

sumAcc(T) = SumAcc{T}(vzero(T))

function add!(acc::SumAcc, x)
    SIMDops.@explicit
    acc.s += x
end

function add!(acc::SumAcc{T}, x::SumAcc{T}) where {T}
    SIMDops.@explicit
    acc.s += x.s
end

Base.sum(acc::SumAcc{T}) where {T<:Vec}  = SumAcc(vsum(acc.s))
Base.sum(acc::SumAcc{T}) where {T<:Real} = acc.s
