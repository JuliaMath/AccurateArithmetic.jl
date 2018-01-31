"""
  `Sorted` should be the first argument to renorm
   when the values to be re-normalized are given
   in order of nonincreasing absolute magnitude.
   The value with the largest exponent is the most
   significant value and appears as the first one;
   the value with the smallest exponent (more negative)
   is the least significant value and appears after
   any other __nonzero__ contributors the the 
   extended precision significand.
"""
struct Sorted end


renorm(a::T) where T<:Real = a

renorm(a::T, b::T) where T<:Real = two_sum(a, b)

renorm(::Type{Sorted}, a::T, b::T) where T<:Real = quick_two_sum(a, b)

function renorm(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = two_sum(b, c)
    x, u = two_sum(a, s)
    y, z = two_sum(u, t)
    x, y = quick_two_sum(x, y)
    return x, y, z
end



function add_(::Type{Sorted}, a::T,b::T,c::T) where {T<:Real}
    s, t = quick_two_sum(b, c)
    x, u = quick_two_sum(a, s)
    y, z = quick_two_sum(u, t)
    x, y = quick_two_sum(x, y)
    return x, y, z
end

function mul_3{T<:AbstractFloat}(a::T, b::T, c::T)
    p, e = mul_(a, b)
    x, p = mul_(p, c)
    y, z = mul_(e, c)
    return x, y, z
end
