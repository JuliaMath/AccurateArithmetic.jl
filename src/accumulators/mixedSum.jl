mutable struct MixedSumAcc{T}
    s :: T
end

mixedSumAcc(::Type{Float32})                   = MixedSumAcc(Float64(0))
mixedSumAcc(::Type{Vec{N, Float32}}) where {N} = MixedSumAcc(vzero(Vec{N, Float64}))

function add!(acc::MixedSumAcc, x)
    @fastmath acc.s += f64(x)
end

function add!(acc::MixedSumAcc{T}, x::MixedSumAcc{T}) where {T}
    @fastmath acc.s += x.s
end

Base.sum(acc::MixedSumAcc{T}) where {T<:Vec}  = MixedSumAcc(vsum(acc.s))
Base.sum(acc::MixedSumAcc{T}) where {T<:Real} = acc.s
