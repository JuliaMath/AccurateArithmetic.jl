"""
    acc_inv(a)


"""
function acc_inv(b::T) where {T<:AbstractFloat}
    hi = inv(b)
    v = hi * b
    w = fma(hi, b, -v)
    lo = (one(T) - v - w) / b
    return hi, lo
end

"""
    acc_div(a, b)

a/b --> (hi_part, lo_part)
acc_div(a,b) == quohi as (hi, lo) (a)/(b)
"""
function acc_div(a::T, b::T) where {T<:AbstractFloat}
    hi = a / b
    v = hi * b
    w = fma(hi, b, -v)
    lo = (a - v - w) / b
    return hi, lo
end


"""
    sqrt(a)

sqrt(a) == Computes `r = fl(sqrt(a))` and `e = err(sqrt(a))`.
"""
function sqrt(a::T) where {T<:AbstractFloat}
    hi = sqrt(a)
    lo = fma(-hi, hi, a) / (hi + hi)
    return hi, lo
end


#=
"Concerning the division, the elementary rounding error is
generally not a floating point number, so it cannot be computed
exactly. Hence we cannot expect to obtain an error
free transformation for the divideision. ...
This means that the computed approximation is as good as
we can expect in the working precision."
-- http://perso.ens-lyon.fr/nicolas.louvet/LaLo05.pdf

While the sqrt algorithm is not strictly an errorfree transformation,
it is known to be reliable and is recommended for general use.
"Augmented precision square roots, 2-D norms and
   discussion on correctly reounding sqrt(x^2 + y^2)"
by Nicolas Brisebarre, Mioara Joldes, Erik Martin-Dorel,
   Hean-Michel Muller, Peter Kornerup
=#
