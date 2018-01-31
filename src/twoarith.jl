function two_sum(a::T, b::T) where T<:Real
    ab =  a + b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end

"""
    fast_two_sum(x, y)::(a, b)

{ ab  =  a + b,  ε  = (a - ab) + b }

__unchecked precondition__: abs(a) >= abs(b).
"""
@inline function fast_two_sum(a::T, b::T) where T<:Real
     ab = a + b
     ε  = a + b - ab
     return ab, ε
end

function two_diff(a::T, b::T) where T<:Real
    ab =  a - b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end


"""
    fast_two_diff(x, y)::(a, b)

{ ab  =  a - b,  ε  = (a - ab) + b }

__unchecked precondition__: abs(a) >= abs(b).
"""
@inline function fast_two_diff(a::T, b::T) where T<:Real
     
     ab = a - b
     ε  = a + b - ab
     return ab, ε
end


@inline function two_prod(a::T, b::T) where T<:Real
    ab =  a * b
    ε  = fma(a, b, -ab)
    return ab, ε
end
