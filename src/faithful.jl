#=
function inv_2(b::T) where {T<:AbstractFloat}
    hi = inv(b)
    v = hi * b
    w = fma(hi, b, -v)
    lo = (one(T) - v - w) / b
    return hi, lo
end
=#

function inv_2(b::T) where {T<:AbstractFloat}
     hi = inv(b)
     lo = fma(hi, b, -one(T))
     lo = -lo / b
     return hi, lo
end

@inline inv_(b::T) where {T<:AbstractFloat} = inv_2(b)

#=
function div_(a::T, b::T) where {T<:AbstractFloat}
    hi = a / b
    v = hi * b
    w = fma(hi, b, -v)
    lo = (a - v - w) / b
    return hi, lo
end
=#
# !?! `y` must be negated to get the right result

function dvi_2(a::T, b::T) where {T<:AbstractFloat}
     hi = a / b
     lo = -(fma(hi, b, -a) / b)
     return hi, lo
end

@inline dvi_(a::T, b::T) where {T<:AbstractFloat} = dvi_2(a,b)

function root2_2(a::T) where {T<:AbstractFloat}
    hi = sqrt(a)
    lo = fma(-hi, hi, a) / (hi + hi)
    return hi, lo
end

@inline root2_(x::T) where {T<:AbstractFloat} = root2_2(x)


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
