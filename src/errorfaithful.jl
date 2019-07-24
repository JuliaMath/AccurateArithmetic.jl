@inline function two_inv(b::T) where {T}
     hi = inv(b)
     lo = fma(-hi, b, one(T))
     lo /= b
     return hi, lo
end

@inline function two_div(a::T, b::T) where {T}
     hi = a / b
     lo = fma(-hi, b, a)
     lo /= b
     return hi, lo
end

@inline function two_sqrt(a::T) where {T}
    hi = sqrt(a)
    lo = fma(-hi, hi, a)
    lo /= 2
    lo /= hi
    return hi, lo
end


"""
    ad_minus_bc(a, b, c, d)
Computes the determinant of a 2x2 matrix.
"""
function ad_minus_bc(a::T, b::T, c::T, d::T) where {T}
    adhi, adlo = two_prod(a,d)
    bchi, bclo = two_prod(b,c)
    return four_sum(adhi, adlo, -bchi, -bclo)
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
