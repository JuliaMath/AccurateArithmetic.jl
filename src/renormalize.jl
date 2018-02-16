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

renorm(::Type{Sorted}, a::T, b::T) where T<:Real = fast_two_sum(a, b)

function renorm(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = two_sum(b, c)
    x, u = two_sum(a, s)
    y, z = two_sum(u, t)
    x, y = two_sum(x, y)
    return x, y, z
end

function renorm_(::Type{Sorted}, a::T,b::T,c::T) where {T<:Real}
    s, t = fast_two_sum(b, c)
    x, u = fast_two_sum(a, s)
    y, z = fast_two_sum(u, t)
    x, y = fast_two_sum(x, y)
    return x, y, z
end

function renorm_3(::Type{Sorted}, ahi::T, amd::T, alo::T) where {T<:Real}
    amd, alo = fast_two_sum(amd, alo)
    ahi, amd = fast_two_sum(ahi, amd)
    amd, alo = fast_two_sum(amd, alo)
    return ahi, amd, alo
end
