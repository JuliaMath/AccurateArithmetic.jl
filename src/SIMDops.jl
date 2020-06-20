module SIMDops
import MacroTools
import SIMDPirates
using  SIMDPirates: Vec, vload, vsum, vabs, vfma, vifelse, vless

# * Generic operations on SIMD packs

fma(x...) = Base.fma(x...)
fma(x::T, y::T, z::T) where {T<:NTuple} = SIMDPirates.vfma(x, y, z)

vzero(x) = zero(x)
vzero(::Type{Vec{W, T}}) where {W, T} = SIMDPirates.vbroadcast(Vec{W, T}, 0)

fptype(::Type{Vec{W, T}}) where {W, T} = T


# * Explicit/exact operations (non-fusible)

eadd(x...) = Base.:+(x...)
eadd(x::T, y::T) where {T<:NTuple} = SIMDPirates.evadd(x, y)

esub(x...) = Base.:-(x...)
esub(x::NTuple) = broadcast(esub, x)
esub(x::VecElement) = VecElement(-x.value)
esub(x::T, y::T) where {T<:NTuple} = SIMDPirates.evsub(x, y)

emul(x...) = Base.:*(x...)
emul(x::T, y::T) where {T<:NTuple} = SIMDPirates.evmul(x, y)

macro explicit(expr)
    MacroTools.postwalk(expr) do x
        x == :+   && return eadd
        x == :-   && return esub
        x == :*   && return emul
        x == :fma && return fma

        if MacroTools.@capture(x, a_ += b_)
            return :($a = $eadd($a, $b))
        end

        return x
    end |> esc
end


# * Fast/fusible operations

fadd(x...) = Base.:+(x...)
fadd(x::T, y::T) where {T<:NTuple} = SIMDPirates.vadd(x, y)

fsub(x...) = Base.:-(x...)
fsub(x::NTuple) = broadcast(esub, x)
fsub(x::T, y::T) where {T<:NTuple} = SIMDPirates.vsub(x, y)

fmul(x...) = Base.:*(x...)
fmul(x::T, y::T) where {T<:NTuple} = SIMDPirates.vmul(x, y)

macro fusible(expr)
    MacroTools.postwalk(expr) do x
        x == :+   && return fadd
        x == :-   && return fsub
        x == :*   && return fmul
        x == :fma && return fma

        if MacroTools.@capture(x, a_ += b_)
            return :($a = $fadd($a, $b))
        end

        return x
    end |> esc
end

end
