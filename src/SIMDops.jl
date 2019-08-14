module SIMDops
import SIMDPirates
using  SIMDPirates: Vec, vload, vsum, vabs, vfma, vifelse, vless

eadd(x...) = Base.:+(x...)
eadd(x::T, y::T) where {T<:NTuple} = SIMDPirates.evadd(x, y)

esub(x...) = Base.:-(x...)
esub(x::NTuple) = broadcast(esub, x)
esub(x::VecElement) = VecElement(-x.value)
esub(x::T, y::T) where {T<:NTuple} = SIMDPirates.evsub(x, y)

emul(x...) = Base.:*(x...)
emul(x::T, y::T) where {T<:NTuple} = SIMDPirates.evmul(x, y)

fma(x...) = Base.fma(x...)
fma(x::T, y::T, z::T) where {T<:NTuple} = SIMDPirates.vfma(x, y, z)

macro explicit()
    quote
        $(esc(:+)) = eadd
        $(esc(:-)) = esub
        $(esc(:*)) = emul
    end
end

vzero(x) = zero(x)
vzero(::Type{Vec{W, T}}) where {W, T} = SIMDPirates.vbroadcast(Vec{W, T}, 0)

fptype(::Type{Vec{W, T}}) where {W, T} = T

end
