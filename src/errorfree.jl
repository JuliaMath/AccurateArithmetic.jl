"""
    two_sum(a, b)

Computes `hi = fl(a+b)` and `lo = err(a+b)`, using the algorithm by D. E. Knuth,
"The Art of Computer Programming: Seminumerical Algorithms", 1969.

This algorithm does not use any branch. See also `fast_two_sum` for an
alternative algorithm which branches but does fewer arithmetic operations.
"""
@inline function two_sum(a::T, b::T) where {T}
    SIMDops.@explicit

    hi = a + b
    v  = hi - a
    lo = (a - (hi - v)) + (b - v)
    return hi, lo
end

"""
    fast_two_sum(a, b)

Computes `hi = fl(a+b)` and `lo = err(a+b)`, using the algorithm by
T. J. Dekker, "A Floating-Point Technique for Extending the Available
Precision", 1971

Despite its name, this algorithm may not be as fast as expected on all hardware
architectures because it branches. See also `two_sum` for an alternative
algorithm which performs more arithmetic operations, but does not branch.
"""
@inline function fast_two_sum(a::T, b::T) where T <: Real
    x = a + b

    if abs(a) < abs(b)
        (a_,b_) = (b,a)
    else
        (a_,b_) = (a,b)
    end

    z = x - a_
    e = b_ - z

    x, e
end

@inline function fast_two_sum(a::T, b::T) where T <: NTuple
    SIMDops.@explicit

    x = a + b

    t = vless(vabs(a), vabs(b))
    a_ = vifelse(t, b, a)
    b_ = vifelse(t, a, b)

    z = x - a_
    e = b_ - z

    x, e
end




"""
   three_sum(a, b, c)

Computes `hi = fl(a+b+c)` and `md = err(a+b+c), lo = err(md)`.
"""
function three_sum(a::T,b::T,c::T) where {T}
    s, t   = two_sum(b, c)
    hi, u  = two_sum(a, s)
    md, lo = two_sum(u, t)
    hi, md = two_hilo_sum(hi, md)
    return hi, md, lo
end

"""
    two_sum(a, b, c)

Computes `hi = fl(a+b+c)` and `lo = err(a+b+c)`.
"""
function two_sum(a::T,b::T,c::T) where {T}
    s, t   = two_sum(b, c)
    hi, u  = two_sum(a, s)
    lo     = u + t
    hi, lo = two_hilo_sum(hi, lo)
    return hi, lo
end

"""
    four_sum(a, b, c, d)

Computes `hi = fl(a+b+c+d)` and `hm = err(a+b+c+d), ml = err(hm), lo = err(ml)`.
"""
function four_sum(a::T,b::T,c::T,d::T) where {T}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    hi, t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    hm, t2 = two_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_sum(t1, t2)
    return hi, hm, ml, lo
end

"""
    three_sum(a, b, c, d)

Computes `hi = fl(a+b+c+d)` and `md = err(a+b+c+d), lo = err(md)`.
"""
function three_sum(a::T,b::T,c::T,d::T) where {T}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    hi, t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    hm, t2 = two_sum(t0, t3) # here, t0 >= t3
    ml     = t1 + t2
    return hi, hm, ml
end

"""
    two_sum(a, b, c, d)

Computes `hi = fl(a+b+c+d)` and `lo = err(a+b+c+d)`.
"""
function two_sum(a::T,b::T,c::T,d::T) where {T}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    hi, t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    lo     = t0 + t3
    return hi, lo
end

"""
    five_sum(a, b, c, d, e)

Computes `s = fl(a+b+c+d+e)` and
    `e1 = err(a+b+c+d), e2 = err(e1), e3 = err(e2), e4 = err(e3)`.
"""
function five_sum(v::T, w::T, x::T, y::T, z::T) where {T}
    t0, t4 = two_sum(y, z)
    t0, t3 = two_sum(x, t0)
    t0, t2 = two_sum(w, t0)
    a, t1  = two_sum(v, t0)
    t0, t3 = two_sum(t3, t4)
    t0, t2 = two_sum(t2, t0)
    b, t1  = two_sum(t1, t0)
    t0, t2 = two_sum(t2, t3)
    c, t1  = two_sum(t1, t0)
    d, e   = two_sum(t1, t2)
    return a, b, c, d, e
end

"""
    two_diff(a, b)
Computes `s = fl(a-b)` and `e = err(a-b)`.
"""
@inline function two_diff(a::T, b::T) where {T}
    hi = a - b
    a1 = hi + b
    b1 = hi - a1
    lo = (a - a1) - (b + b1)
    return hi, lo
end
"""
    three_diff(a, b, c)

Computes `s = fl(a-b-c)` and `e1 = err(a-b-c), e2 = err(e1)`.
"""
function three_diff(a::T,b::T,c::T) where {T}
    s, t = two_diff(-b, c)
    x, u = two_sum(a, s)
    y, z = two_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    four_diff(a, b, c, d)

Computes `hi = fl(a-b-c-d)` and `hm = err(a-b-c-d), ml = err(hm), lo = err(ml)`.
"""
function four_diff(a::T,b::T,c::T,d::T) where {T}
    t0, t1 = two_diff(a ,  b)
    t0, t2 = two_diff(t0,  c)
    hi, t3 = two_diff(t0,  d)
    t0, t1 = two_sum(t1, t2)
    hm, t2 = two_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_sum(t1, t2)
    return hi, hm, ml, lo
end

"""
    two_square(a)
Computes `s = fl(a*a)` and `e = err(a*a)`.
"""
@inline function two_square(a::T) where {T}
    p = a * a
    e = fma(a, a, -p)
    p, e
end


"""
    two_prod(a, b)
Computes `s = fl(a*b)` and `e = err(a*b)`.
"""
@inline function two_prod(a::T, b::T) where {T}
    p = a * b
    e = fma(a, b, -p)
    p, e
end

@inline function two_prod(a::T, b::T) where {T<:NTuple}
    SIMDops.@explicit
    p = a * b
    # TODO: add vfma to @explicit so that this method can be merged with the
    # generic one
    e = vfma(a, b, -p)
    p, e
end


"""
    three_prod(a, b, c)

Computes `hi = fl(a*b*c)` and `md = err(a*b*c), lo = err(md)`.
"""
function three_prod(a::T, b::T, c::T) where {T}
    abhi, ablo = two_prod(a, b)
    hi, abhiclo = two_prod(abhi, c)
    ablochi, abloclo = two_prod(ablo, c)
    md, lo, tmp  = three_sum(ablochi, abhiclo, abloclo)
    return hi, md, lo
end

#=
   three_fma algorithm from
   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
   three_fma(a, b, c)
Computes `s = fl(fma(a,b,c))` and `e1 = err(fma(a,b,c)), e2 = err(e1)`.
"""
function three_fma(a::T, b::T, c::T) where {T}
     x = fma(a, b, c)
     y, z = two_prod(a, b)
     t, z = two_sum(c, z)
     t, u = two_sum(y, t)
     y = ((t - x) + u)
     y, z = two_hilo_sum(y, z)
     return x, y, z
end



# with arguments sorted by magnitude

"""
    two_hilo_sum(a, b)
*unchecked* requirement `|a| ≥ |b|`
Computes `hi = fl(a+b)` and `lo = err(a+b)`.
"""
@inline function two_hilo_sum(a::T, b::T) where {T}
    hi = a + b
    lo = b - (hi - a)
    return hi, lo
end

"""
    two_lohi_sum(a, b)
*unchecked* requirement `|b| ≥ |a|`
Computes `hi = fl(a+b)` and `lo = err(a+b)`.
"""
@inline function two_lohi_sum(a::T, b::T) where {T}
    hi = b + a
    lo = a - (hi - b)
    return hi, lo
end

"""
    two_hilo_diff(a, b)

*unchecked* requirement `|a| ≥ |b|`
Computes `hi = fl(a-b)` and `lo = err(a-b)`.
"""
@inline function two_hilo_diff(a::T, b::T) where {T}
    hi = a - b
    lo = (a - hi) - b
    hi, lo
end

"""
    two_lohi_diff(a, b)

*unchecked* requirement `|b| ≥ |a|`
Computes `hi = fl(a-b)` and `lo = err(a-b)`.
"""
@inline function two_lohi_diff(a::T, b::T) where {T}
    hi = b - a
    lo = (b - hi) - a
    hi, lo
end



"""
    three_hilo_sum(a, b, c)

*unchecked* requirement `|a| ≥ |b| ≥ |c|`
Computes `x = fl(a+b+c)` and `y = err(a+b+c), z = err(y)`.
"""
function three_hilo_sum(a::T,b::T,c::T) where {T}
    s, t = two_hilo_sum(b, c)
    x, u = two_hilo_sum(a, s)
    y, z = two_hilo_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    three_lohi_sum(a, b, c)

*unchecked* requirement `|c| ≥ |b| ≥ |a|`
Computes `x = fl(a+b+c)` and `y = err(a+b+c), z = err(y)`.
"""
function three_lohi_sum(a::T,b::T,c::T) where {T}
    s, t = two_hilo_sum(b, a)
    x, u = two_hilo_sum(c, s)
    y, z = two_hilo_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    three_hilo_diff(a, b, c)

*unchecked* requirement `|a| ≥ |b| ≥ |c|`
Computes `x = fl(a-b-c)` and `y = err(a-b-c), z = err(y)`.
"""
function three_hilo_diff(a::T,b::T,c::T) where {T}
    s, t = two_hilo_diff(b, -c)
    x, u = two_hilo_sum(a, s)
    y, z = two_hilo_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    three_lohi_diff(a, b, c)

*unchecked* requirement `|c| ≥ |b| ≥ |a|`
Computes `x = fl(a-b-c)` and `y = err(a-b-c), z = err(y)`.
"""
function three_lohi_diff(c::T,b::T,a::T) where {T}
    s, t = two_hilo_diff(b, -c)
    x, u = two_hilo_sum(a, s)
    y, z = two_hilo_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    four_hilo_sum(a, b, c, d)

*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `hi = fl(a+b+c+d)` and `hm = err(a+b+c+d), ml = err(hm), lo = err(ml)`.
"""
function four_hilo_sum(a::T,b::T,c::T,d::T) where {T}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    hm, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_hilo_sum(t1, t2)
    return hi, hm, ml, lo
end

"""
    four_lohi_sum(a, b, c, d)

*unchecked* requirement `|d| ≥ |c| ≥ |b| ≥ |a|`
Computes `hi = fl(a+b+c+d)` and `hm = err(a+b+c+d), ml = err(hm), lo = err(ml)`.
"""
function four_lohi_sum(d::T,c::T,b::T,a::T) where {T}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    hm, t2 = two_hilo_sum(t0, t3)
    ml, lo = two_hilo_sum(t1, t2)
    return hi, hm, ml, lo
end


"""
    four_hilo_diff(a, b, c, d)

*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `hi = fl(a-b-c-d)` and `hm = err(a-b-c-d), ml = err(hm), lo = err(ml)`.
"""
function four_hilo_diff(a::T,b::T,c::T,d::T) where {T}
    t0, t1 = two_hilo_diff(a,  b)
    t0, t2 = two_hilo_diff(t0,  c)
    hi, t3 = two_hilo_diff(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    hm, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_hilo_sum(t1, t2)
    return hi, hm, ml, lo
end


"""
    four_hilo_diff(a, b, c, d)

*unchecked* requirement `|d| ≥ |c| ≥ |b| ≥ |a|`
Computes `hi = fl(a-b-c-d)` and `hm = err(a-b-c-d), ml = err(hm), lo = err(ml)`.
"""
function four_lohi_diff(d::T,c::T,b::T,a::T) where {T}
    t0, t1 = two_hilo_diff(a,  b)
    t0, t2 = two_hilo_diff(t0,  c)
    hi, t3 = two_hilo_diff(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    hm, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_hilo_sum(t1, t2)
    return hi, hm, ml, lo
end
