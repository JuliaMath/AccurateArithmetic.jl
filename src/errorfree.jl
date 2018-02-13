# this is "TwoSum"
@inline function add_(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

@inline function add_2(a::T, b::T) where {T<:AbstractFloat}
    return add_(a, b)
end

# ThreeSum
function add_(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_(b, c)
    x, u = add_(a, s)
    y, z = add_(u, t)
    x, y = add_(x, y)
    return x, y, z
end

@inline function add_3(a::T, b::T, c::T) where {T<:AbstractFloat}
    return add_(a, b, c)
end

function add_2(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_(b, c)
    x, u = add_(a, s)
    y    = u + t
    x, y = add_(x, y)
    return x, y
end

# FourSum
function add_(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_(a ,  b)
    t0, t2 = add_(t0,  c)
    a,  t3 = add_(t0,  d)
    t0, t1 = add_(t1, t2)
    b,  t2 = add_(t0, t3)
    c,  d  = add_(t1, t2)
    return a, b, c, d
end

function add_2(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_(a ,  b)
    t0, t2 = add_(t0,  c)
    a,  t3 = add_(t0,  d)
    t0  = t1 + t2
    b   = t0 + t3
    return a, b
end

function add_3(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_(a ,  b)
    t0, t2 = add_(t0,  c)
    a,  t3 = add_(t0,  d)
    t0, t1 = add_(t1, t2)
    b,  t2 = add_(t0, t3)
    c  = t1 + t2
    return a, b, c
end

# FiveSum
function add_(a::T, b::T, c::T, d::T, e::T) where {T<:AbstractFloat}
    t0, t4 = add_(y, z)
    t0, t3 = add_(x, t0)
    t0, t2 = add_(w, t0)
    a, t1  = add_(v, t0)
    t0, t3 = add_(t3, t4)
    t0, t2 = add_(t2, t0)
    b, t1  = add_(t1, t0)
    t0, t2 = add_(t2, t3)
    c, t1  = add_(t1, t0)
    d, e   = add_(t1, t2)
    return a, b, c, d, e
end


# this is TwoDiff
@inline function sub_(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)
    return s, e
end

function sub_(a::T, b::T, c::T) where {T<:AbstractFloat}
    s, t = sub_(-b, c)
    x, u = add_(a, s)
    y, z = add_(u, t)
    x, y = add_(x, y)
    return x, y, z
end


# this is QuickTwoSum, presumes abs(a) >= abs(b)
@inline function add_hilo_(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

# QuickThreeSum, presumes abs(a) >= abs(b) >= abs(c)
function add_hilo_(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo_(b, c)
    x, u = add_hilo_(a, s)
    y, z = add_hilo_(u, t)
    x, y = add_hilo_(x, y)
    return x, y, z
end

# QuickFourSum, presumes abs(a) >= abs(b) >= abs(c) >= abs(d)
function add_hilo_(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_hilo_(a ,  b)
    t0, t2 = add_hilo_(t0,  c)
    a,  t3 = add_hilo_(t0,  d)
    t0, t1 = add_hilo_(t1, t2)
    b,  t2 = add_hilo_(t0, t3)
    c,  d  = add_hilo_(t1, t2)
    return a, b, c, d
end

# QuickFiveSum presumes abs(a) >= abs(b) >= abs(c) >= abs(d) >= abs(e)
function add_hilo_(a::T, b::T, c::T, d::T, e::T) where {T<:AbstractFloat}
    t0, t4 = add_hilo_(y, z)
    t0, t3 = add_hilo_(x, t0)
    t0, t2 = add_hilo_(w, t0)
    a, t1  = add_hilo_(v, t0)
    t0, t3 = add_hilo_(t3, t4)
    t0, t2 = add_hilo_(t2, t0)
    b, t1  = add_hilo_(t1, t0)
    t0, t2 = add_hilo_(t2, t3)
    c, t1  = add_hilo_(t1, t0)
    d, e   = add_hilo_(t1, t2)
    return a, b, c, d, e
end

# this is QuickTwoDiff, requires abs(a) >= abs(b)
@inline function sub_hilo_(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

function sub_hilo_(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo_(-b, c)
    x, u = add_hilo_(a, s)
    y, z = add_hilo_(u, t)
    x, y = add_hilo_(x, y)
    return x, y, z
end

# this is TwoProdFMA
@inline function mul_(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    return p, e
end

@inline function mul_2(a::T, b::T) where {T<:AbstractFloat}
    return mul_(a, b)
end

"""
    mul_(x1, x2)
    mul_(x1, x2, x3)

mul_(x1, x2) returns a two tuple
mul_(x1, x2, x3) returns a three tuple
""" mul_

"""
    mul_2(xs...)

returns a two tuple
""" mul_2

"""
    mul_3(xs...)

returns a three tuple for 3 xs
""" mul_2

function mul_2(a::T, b::T, c::T) where {T<:AbstractFloat}
    y = a*b; z = fma(a, b, -y)
    x = y*c; y = fma(y, c, -x)
    z = fma(z,c,y)
    return x, z
end

function mul_3(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_(a, b)
    x, y = mul_(y, c)
    z, t = mul_(z, c)
    y, z = add_hilo_(y, z)
    z += t
    return x, y, z
end


# a squared
@inline function sqr_(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    return p, e
end

# a cubed
@inline function cub_(a::T) where {T<:AbstractFloat}
    hi, lo = sqr_(a)
    hihi, _hilo = mul_(hi, a)
    lohi, lolo = mul_(lo, a)
    _hilo, lohi = add_hilo_(_hilo, lohi)
    hi, lo = add_hilo_(hihi, _hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   xfma algorithm from
   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    fma_(a, b, c) => (x, y, z)

Computes `x = fl(fma_(a, b, c))` and `y, z = fl(err(fma_(a, b, c)))`.
"""
function fma_(a::T, b::T, c::T) where {T<:AbstractFloat}
     x = fma(a, b, c)
     y, z = mul_(a, b)
     t, z = add_(c, z)
     t, u = add_(y, t)
     y = ((t - x) + u)
     y, z = add_hilo_(y, z)
     return x, y, z
end

"""
    fms_(a, b, c) => (x, y, z)

Computes `x = fl(fms_(a, b, c))` and `y, z = fl(err(fms_(a, b, c)))`.
"""
@inline function fms_(a::T, b::T, c::T) where {T<:AbstractFloat}
     return fma_(a, b, -c)
end
