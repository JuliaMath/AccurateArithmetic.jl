# this is "TwoSum"
@inline function add(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

# ThreeSum
function add(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add(b, c)
    x, u = add(a, s)
    y, z = add(u, t)
    x, y = add_hilo(x, y)
    return x, y, z
end

# FourSum
function add(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add(a ,  b)
    t0, t2 = add(t0,  c)
    a,  t3 = add(t0,  d)
    t0, t1 = add(t1, t2)
    b,  t2 = add(t0, t3)
    c,  d  = add_hilo(t1, t2)
    return a, b, c, d
end

# this is TwoDiff
@inline function sub(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)
    return s, e
end

function sub(a::T, b::T, c::T) where {T<:AbstractFloat}
    s, t = sub(-b, c)
    x, u = add(a, s)
    y, z = add(u, t)
    x, y = add_hilo(x, y)
    return x, y, z
end

# this is QuickTwoSum, requires abs(a) >= abs(b)
@inline function add_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

function add_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo(b, c)
    x, u = add_hilo(a, s)
    y, z = add_hilo(u, t)
    x, y = add_hilo(x, y)
    return x, y, z
end

# this is QuickTwoDiff, requires abs(a) >= abs(b)
@inline function sub_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

function sub_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo(-b, c)
    x, u = add_hilo(a, s)
    y, z = add_hilo(u, t)
    x, y = add_hilo(x, y)
    return x, y, z
end

# this is TwoProdFMA
@inline function mul(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    p, e
end

function mul(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul(a, b)
    x, y = mul(y, c)
    z, t = mul(z, c)
    return x, y, z, t
end

"""
    mul_3(a, b, c)

similar to mul(a, b, c)
returns a three tuple
"""
function mul_3(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul(a, b)
    x, y = mul(y, c)
    z    *= c
    return x, y, z
end

# a squared
@inline function sqr(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    p, e
end

# a cubed
@inline function cub(a::T) where {T<:AbstractFloat}
    hi, lo = sqr(a)
    hihi, _hilo = mul(hi, a)
    lohi, lolo = mul(lo, a)
    _hilo, lohi = add_hilo(_hilo, lohi)
    hi, lo = add_hilo(hihi, _hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   fma_hilo algorithm from
   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    acc_fma(a, b, c) => (x, y, z)

Computes `x = fl(fma(a, b, c))` and `y, z = fl(err(fma(a, b, c)))`.
"""
function acc_fma(a::T, b::T, c::T) where {T<:AbstractFloat}
     x = fma(a, b, c)
     y, z = mul(a, b)
     t, z = add(c, z)
     t, u = add(y, t)
     y = ((t - x) + u)
     y, z = add_hilo(y, z)
     return x, y, z
end

"""
    fms_(a, b, c) => (x, y, z)

Computes `x = fl(fms(a, b, c))` and `y, z = fl(err(fms(a, b, c)))`.
"""
@inline function fms_(a::T, b::T, c::T) where {T<:AbstractFloat}
     return acc_fma(a, b, -c)
end

