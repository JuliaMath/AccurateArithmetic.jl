# this is "TwoSum"
@inline function add_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

# ThreeSum
function add_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_acc(b, c)
    x, u = add_acc(a, s)
    y, z = add_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

# FourSum
function add_acc(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_acc(a ,  b)
    t0, t2 = add_acc(t0,  c)
    a,  t3 = add_acc(t0,  d)
    t0, t1 = add_acc(t1, t2)
    b,  t2 = add_acc(t0, t3)
    c,  d  = add_hilo_acc(t1, t2)
    return a, b, c, d
end

# this is TwoDiff
@inline function sub_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)
    return s, e
end

function sub_acc(a::T, b::T, c::T) where {T<:AbstractFloat}
    s, t = sub_acc(-b, c)
    x, u = add_acc(a, s)
    y, z = add_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

# this is QuickTwoSum, requires abs(a) >= abs(b)
@inline function add_hilo_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

function add_hilo_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo_acc(b, c)
    x, u = add_hilo_acc(a, s)
    y, z = add_hilo_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

# this is QuickTwoDiff, requires abs(a) >= abs(b)
@inline function sub_hilo_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

function sub_hilo_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo_acc(-b, c)
    x, u = add_hilo_acc(a, s)
    y, z = add_hilo_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

# this is TwoProdFMA
@inline function mul_acc(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    return p, e
end

function mul_acc(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_acc(a, b)
    x, y = mul_acc(y, c)
    z, t = mul_acc(z, c)
    return x, y, z, t
end

"""
    mul_acc3(a, b, c)

similar to mul_acc(a, b, c)
returns a three tuple
"""
function mul_acc3(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_acc(a, b)
    x, y = mul_acc(y, c)
    z    *= c
    return x, y, z
end

# a squared
@inline function sqr_acc(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    return p, e
end

# a cubed
@inline function cub_acc(a::T) where {T<:AbstractFloat}
    hi, lo = sqr_acc(a)
    hihi, _hilo = mul_acc(hi, a)
    lohi, lolo = mul_acc(lo, a)
    _hilo, lohi = add_hilo_acc(_hilo, lohi)
    hi, lo = add_hilo_acc(hihi, _hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   x
   fma algorithm from
   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    fma_acc(a, b, c) => (x, y, z)

Computes `x = fl(fma_acc(a, b, c))` and `y, z = fl(err(fma_acc(a, b, c)))`.
"""
function fma_acc(a::T, b::T, c::T) where {T<:AbstractFloat}
     x = fma(a, b, c)
     y, z = mul_acc(a, b)
     t, z = add_acc(c, z)
     t, u = add_acc(y, t)
     y = ((t - x) + u)
     y, z = add_hilo_acc(y, z)
     return x, y, z
end

"""
    fms_acc(a, b, c) => (x, y, z)

Computes `x = fl(fms_acc(a, b, c))` and `y, z = fl(err(xfms_acc(a, b, c)))`.
"""
@inline function fms_acc(a::T, b::T, c::T) where {T<:AbstractFloat}
     return fma_acc(a, b, -c)
end
