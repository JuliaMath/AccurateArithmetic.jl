"""
    inv_acc(a)


"""
function inv_acc(b::T) where {T<:AbstractFloat}
    hi = inv(b)
    v = hi * b
    w = fma(hi, b, -v)
    lo = (one(T) - v - w) / b
    return hi, lo
end

"""
    div_acc(a, b)

a/b --> (hi_part, lo_part)
div_acc(a,b) == quohi as (hi, lo) (a)/(b)
"""
function div_acc(a::T, b::T) where {T<:AbstractFloat}
    hi = a / b
    v = hi * b
    w = fma(hi, b, -v)
    lo = (a - v - w) / b
    return hi, lo
end


"""
    sqrt_acc(a)

sqrt_acc(a) == Computes `r = fl(xsqrt(a))` and `e = err(xsqrt(a))`.
"""
function sqrt_acc(a::T) where {T<:AbstractFloat}
    hi = sqrt(a)
    lo = fma(-hi, hi, a) / (hi + hi)
    return hi, lo
end


#=
"Concerning the division, the elementary rounding error is
generally not a floating point number, so it cannot be computed
exactly. Hence we cannot expect to obtain an error
free transformation for the xdivision. ...
This means that the computed approximation is as good as
we can expect in the working precision."
-- http://perso.ens-lyon.fr/nicolas.louvet/LaLo05.pdf

While the sqrt algorithm is not strictly an errorfree transformation,
it is known to be reliable and is recommended for general use.
"Augmented precision square roots, 2-D norms and
   discussion on correctly reounding xsqrt(x^2 + y^2)"
by Nicolas Brisebarre, Mioara Joldes, Erik Martin-Dorel,
   Hean-Michel Muller, Peter Kornerup
=#
