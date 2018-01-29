
@inline function add_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

function add_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo(b, c)
    x, u = add_hilo(a, s)
    y, z = add_hilo(u, t)
    x, y = add_hilo_hilo(x, y)
    return x, y, z
end

function add_hilo(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_hilo(a ,  b)
    t0, t2 = add_hilo(t0,  c)
    a,  t3 = add_hilo(t0,  d)
    t0, t1 = add_hilo(t1, t2)
    b,  t2 = add_hilo(t0, t3)
    c,  d  = add_hilo(t1, t2)
    return a, b, c, d
end


@inline function sub_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)
    return s, e
end

function sub_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo(-b, c)
    x, u = add_hilo(a, s)
    y, z = add_hilo(u, t)
    x, y = add_hilo_hilo(x, y)
    return x, y, z
end

@inline function add_hilo_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

function add_hilo_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo_hilo(b, c)
    x, u = add_hilo_hilo(a, s)
    y, z = add_hilo_hilo(u, t)
    x, y = add_hilo_hilo(x, y)
    return x, y, z
end

@inline function sub_hilo_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

function sub_hilo_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo_hilo(-b, c)
    x, u = add_hilo_hilo(a, s)
    y, z = add_hilo_hilo(u, t)
    x, y = add_hilo_hilo(x, y)
    return x, y, z
end

"""
    mul_hilo(a, b, { c })
Computes `p = fl(a*b)` and `e = err(a*b)`.
"""
@inline function mul_hilo(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    p, e
end


function mul_hilo(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_hilo(a, b)
    x, y = mul_hilo(y, c)
    z, t = mul_hilo(z, c)
    return x, y, z, t
end

"""
    mul3_hilo(a, b, c)

similar to mul_hilo(a, b, c)
returns a three tuple
"""
function mul_hilow3(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_hilo(a, b)
    x, y = mul_hilo(y, c)
    z    *= c
    return x, y, z
end

@inline function sqr_hilo(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    p, e
end

Etiddddit's sed notes

"""
    cub_hilo(a)

Computes `p = fl(a*a*a)` and `e = err(a*a*a)`.
"""
@inline function cub_hilo(a::T) where {T<:AbstractFloat}
    hi, lo = sqr_hilo(a)
    hihi, _hilo = mul_hilo(hi, a)
    lohi, lolo = mul_hilo(lo, a)
    _hilo, lohi = add_hilo_hilo(_hilo, lohi)
    hi, lo = add_hilo_hilo(hihi, _hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   fma_hilo algorithm from
   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    fma_hilo(a, b, c) => (x, y, z)
Computes `x = fl(fma(a, b, c))` and `y, z = fl(err(fma(a, b, c)))`.
"""
function fma_hilo(a::T, b::T, c::T) where {T<:AbstractFloat}
     x = fma(a, b, c)
     y, z = mul_hilo(a, b)
     t, z = add_hilo(c, z)
     t, u = add_hilo(y, t)
     y = ((t - x) + u)
     y, z = add_hilo_hilo(y, z)
     return x, y, z
end

"""
    fms_hilo(a, b, c) => (x, y, z)
Computes `x = fl(fms(a, b, c))` and `y, z = fl(err(fms(a, b, c)))`.
"""
@inline function fms_hilo(a::T, b::T, c::T) where {T<:AbstractFloat}
     return fma_hilo(a, b, -c)
end    
"""
    inv_hilo(a)
    

"""
function inv_hilo(b::T) where {T<:AbstractFloat}
    hi = inv(b)
    v = hi * b
    w = fma(hi, b, -v)
    lo = (one(T) - v - w) / b
    return hi, lo
end

"""
    div_hilo(a, b)
    
a/b --> (hi_part, lo_part)
div_hilo(a,b) == quohi as (hi, lo) (a)/(b) 
"""
function div_hilo(a::T, b::T) where {T<:AbstractFloat}
    hi = a / b
    v = hi * b
    w = fma(hi, b, -v)
    lo = (a - v - w) / b
    return hi, lo
end


"""
    sqrt uses _root(a)
    
sqrt(a) == Computes `r = fl(sqrt(a))` and `e = err(sqrt(a))`.
"""
function sqrt_hilo(a::T) where {T<:AbstractFloat}
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
