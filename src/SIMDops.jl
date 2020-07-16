module SIMDops
import SIMDPirates
using  SIMDPirates: Vec, vload, vsum, vabs, vfma, vifelse, vless, vzero


# * Generic operations on SIMD packs

fma(x...) = Base.fma(x...)
fma(x::T, y::T, z::T) where {T<:NTuple} = SIMDPirates.vfma(x, y, z)

fptype(::Type{Vec{W, T}}) where {W, T} = T

# TODO: This probably belong to SIMDPirates
@inline f64(x::Number)     = Float64(x)
@inline f64(x::VecElement) = VecElement(f64(x.value))
@inline f64(x::Vec)        = broadcast(f64, x)


# * Macros rewriting mathematical operations

# ** Helper functions

replace_simd_ops(x, _, _) = x

function replace_simd_ops(sym::Symbol, ops, updates)
    # Replace e.g:  +
    #           =>  eadd
    for (op, replacement) in ops
        sym === op && return replacement
    end
    sym
end

function replace_simd_ops(expr::Expr, ops, updates)
    # Replace e.g:  lhs += rhs
    #           =>  lhs = eadd(lhs, rhs)
    for (op, replacement) in updates
        if expr.head === op
            lhs = expr.args[1]
            rhs = replace_simd_ops(expr.args[2], ops, updates)
            return :($lhs = $replacement($lhs, $rhs))
        end
    end

    newexpr = Expr(replace_simd_ops(expr.head, ops, updates))
    for arg in expr.args
        push!(newexpr.args, replace_simd_ops(arg, ops, updates))
    end
    newexpr
end

# ** Explicit/exact operations (non-fusible)

eadd(x...) = Base.:+(x...)
eadd(x::T, y::T) where {T<:NTuple} = SIMDPirates.evadd(x, y)

esub(x...) = Base.:-(x...)
esub(x::NTuple) = broadcast(esub, x)
esub(x::VecElement) = VecElement(-x.value)
esub(x::T, y::T) where {T<:NTuple} = SIMDPirates.evsub(x, y)

emul(x...) = Base.:*(x...)
emul(x::T, y::T) where {T<:NTuple} = SIMDPirates.evmul(x, y)

function explicit(expr::Expr)
    replace_simd_ops(expr,
                     (:+   => eadd,
                      :-   => esub,
                      :*   => emul,
                      :fma => fma),
                     (:+=  => eadd,
                      :-=  => esub,
                      :*=  => emul))
end

macro explicit(expr)
    explicit(expr) |> esc
end


# * Fast/fusible operations

fadd(x...) = Base.:+(x...)
fadd(x::T, y::T) where {T<:NTuple} = SIMDPirates.vadd(x, y)

fsub(x...) = Base.:-(x...)
fsub(x::NTuple) = broadcast(esub, x)
fsub(x::T, y::T) where {T<:NTuple} = SIMDPirates.vsub(x, y)

fmul(x...) = Base.:*(x...)
fmul(x::T, y::T) where {T<:NTuple} = SIMDPirates.vmul(x, y)

function fusible(expr::Expr)
    replace_simd_ops(expr,
                     (:+   => fadd,
                      :-   => fsub,
                      :*   => fmul,
                      :fma => fma),
                     (:+=  => fadd,
                      :-=  => fsub,
                      :*=  => fmul))
end

macro fusible(expr)
    fusible(expr) |> esc
end

end
