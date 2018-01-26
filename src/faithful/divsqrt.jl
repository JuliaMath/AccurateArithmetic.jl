"""
    inv_acc(a)
    
Computes `q = fl(inv(a))` and `e = err(inv(a))`.
"""
function inv_acc(b::T) where {T<:AbstractFloat}
    x = one(T) / b
    y = fma(-x, b, one(T))
    return x, y
end

"""
    div_acc(a, b)

Computes `q = fl(a/b)` and `e = err(a/b)`.
"""
function div_acc(a::T, b::T) where {T<:AbstractFloat}
    x = a / b
    y = fma(-x, b, a) / a
    return x, y
end


"""
    sqrt_acc(a)
    
Computes `r = fl(sqrt(a))` and `e = err(sqrt(a))`.
"""
function sqrt_acc(a::T) where {T<:AbstractFloat}
    x = sqrt(a)
    y = fma(-x, x, a) / (x + x)
    return x, y
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
