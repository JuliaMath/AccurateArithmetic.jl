@inline function add_eft(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

function add_eft(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_eft(b, c)
    x, u = add_eft(a, s)
    y, z = add_eft(u, t)
    x, y = add_hilo_eft(x, y)
    return x, y, z
end

function add_eft(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_eft(a ,  b)
    t0, t2 = add_eft(t0,  c)
    a,  t3 = add_eft(t0,  d)
    t0, t1 = add_eft(t1, t2)
    b,  t2 = add_eft(t0, t3)
    c,  d  = add_eft(t1, t2)
    return a, b, c, d
end


@inline function sub_eft(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)
    return s, e
end

function sub_eft(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_eft(-b, c)
    x, u = add_eft(a, s)
    y, z = add_eft(u, t)
    x, y = add_hilo_eft(x, y)
    return x, y, z
end

@inline function add_hilo_eft(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

function add_hilo_eft(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo_eft(b, c)
    x, u = add_hilo_eft(a, s)
    y, z = add_hilo_eft(u, t)
    x, y = add_hilo_eft(x, y)
    return x, y, z
end

@inline function sub_hilo_eft(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

function sub_hilo_eft(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo_eft(-b, c)
    x, u = add_hilo_eft(a, s)
    y, z = add_hilo_eft(u, t)
    x, y = add_hilo_eft(x, y)
    return x, y, z
end

"""
    mul_eft(a, b, { c })

Computes `p = fl(a*b)` and `e = err(a*b)`.
"""
@inline function mul_eft(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    p, e
end


function mul_eft(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_eft(a, b)
    x, y = mul_eft(y, c)
    z, t = mul_eft(z, c)
    return x, y, z, t
end

"""
    mul3_eft(a, b, c)

similar to mul_eft(a, b, c)

returns a three tuple
"""
function mul3_eft(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_eft(a, b)
    x, y = mul_eft(y, c)
    z    *= c
    return x, y, z
end

"""
    sqr_eft(a)

Computes `p = fl(a*a)` and `e = err(a*a)`.
"""
@inline function sqr_eft(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    p, e
end


"""
    cub_eft(a)

Computes `p = fl(a*a*a)` and `e = err(a*a*a)`.
"""
@inline function cub_eft(a::T) where {T<:AbstractFloat}
    hi, lo = sqr_eft(a)
    hihi, _hilo = mul_eft(hi, a)
    lohi, lolo = mul_eft(lo, a)
    _hilo, lohi = add_hilo_eft(_hilo, lohi)
    hi, lo = add_hilo_eft(hihi, _hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   fma_eft algorithm from

   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    fma_eft(a, b, c) => (x, y, z)

Computes `x = fl(fma(a, b, c))` and `y, z = fl(err(fma(a, b, c)))`.
"""
function fma_eft(a::T, b::T, c::T) where {T<:AbstractFloat}
     x = fma(a, b, c)
     y, z = mul_eft(a, b)
     t, z = add_eft(c, z)
     t, u = add_eft(y, t)
     y = ((t - x) + u)
     y, z = add_hilo_eft(y, z)
     return x, y, z
end

"""
    fms_eft(a, b, c) => (x, y, z)

Computes `x = fl(fms(a, b, c))` and `y, z = fl(err(fms(a, b, c)))`.
"""
@inline function fms_eft(a::T, b::T, c::T) where {T<:AbstractFloat}
     return fma_eft(a, b, -c)
end    

"""
    add_eft(a, b, { c, { d }})

accurate addition with 2, 3, or 4 floats

returns the same number of floats,
transformed to separate significands
as a tuple of decreasing magnitudes
""" add_eft

"""
    add_hilo_eft(a, b, { c })
    
*unchecked* `|a| ≥ |b|` `{|b| ≥ |c| }`

accurate addition with 2 or 3 floats
given in order of nonincreasing magnitude

returns the same number of floats,
transformed to separate significands
as a tuple of decreasing magnitudes
""" add_hilo_eft

"""
    sub_eft(a, b, { c, { d }})

accurate subtraction with 2, 3, or 4 floats

returns the same number of floats,
transformed to separate significands
as a tuple of decreasing magnitudes
""" sub_eft

"""
    sub_hilo_eft(a, b, { c })
    
*unchecked* requirement `|a| ≥ |b|` {`|b| ≥ |c|`}

accurate subtraction with 2 or 3 floats
given in order of nonincreasing magnitude

returns the same number of floats,
transformed to separate significands
as a tuple of decreasing magnitudes
""" sub_hilo_eft

"""
    mul_eft(a, b)    --> (x, y)
    mul_eft(a, b, c) --> (x, y, z, t)
    mul3_eft(a, b, c) --> (x, y, z)

`a * b == x + y`
`a * b * c == x + y + z + t`
"""
