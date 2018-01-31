# use HiLo as first arg to renorm when values
# are ordered by decreasing magnitude
struct HiLo end  


"""
    fast_two_sum(a, b)

- ab = a + b  
- ε  = a + b - ab    
- ab + ε == ab
- ab ⊕ ε == a ⊕ b    

"""
@inline function fast_two_sum(a::T, b::T) where T<:Real
     @confirm abs(a) > abs(b)
     
     ab = a + b
     ε  = (a - ab) + b
     return ab, ε 
end

function two_sum(a::T, b::T) where T<:Real
    ab =  a + b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end

function two_prod(a::T, b::T) where T<:Real
    ab =  a * b
    ε  = fma(a, b, -ab)
    return ab, ε
end


function renorm(::HiLo}, a::T, b::T) where T<:Real
     @confirm abs(a) > abs(b)
     return fast_two_sum(a, b)

end


function renoer(a::T, b::T, c::T) where T<:Real
     @confirm abs(a) >= abs(b) >= abs(c)
  
    t₁, t₂ = fast_two_sum(b, c)
    t₃, t₁ = fast_two_sum(a, t₁)
    t₁, t₂ = fast_two_sum(t₁,t₂)
  
    return t₁, t₂, t₃
end



function renorm(a::T, b::T) where T<:Real
    ab =  a + b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end

function renorm_inorder(a::T, b::T, c::T) where T<:Real
    @confirm abs(a) > abs(b) > abs(c)
     
    ab =  a + b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end

