mutable struct MixedDotAcc{T}
    s :: T
end

mixedDotAcc(::Type{Float32})                   = MixedDotAcc(Float64(0))
mixedDotAcc(::Type{Vec{N, Float32}}) where {N} = MixedDotAcc(vzero(Vec{N, Float64}))

function add!(acc::MixedDotAcc, x, y)
    @fastmath acc.s += f64(x) * f64(y)
end

function add!(acc::MixedDotAcc{T}, x::MixedDotAcc{T}) where {T}
    @fastmath acc.s += x.s
end

Base.sum(acc::MixedDotAcc{T}) where {T<:Vec}  = MixedDotAcc(vsum(acc.s))
Base.sum(acc::MixedDotAcc{T}) where {T<:Real} = acc.s
