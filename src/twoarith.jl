function two_sum(a::T, b::T) where T<:Real
    ab =  a + b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end

function two_diff(a::T, b::T) where T<:Real
    ab =  a - b
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
     ab =  a + b
     B  = ab - a
     ε  =  b - B
     return ab, ε
end

"""
    fast_two_diff(x, y)::(a, b)

{ ab  =  a - b,  ε  = (a - ab) + b }

__unchecked precondition__: abs(a) >= abs(b).
"""
@inline function fast_two_diff(a::T, b::T) where T<:Real     
     ab =  a - b
     B  = ab - a
     ε  =  B - b
     return ab, ε
end

@inline function two_prod(a::T, b::T) where T<:Real
    ab =  a * b
    ε  = fma(a, b, -ab)
    return ab, ε
end

#=
   Separate an IEEEFloat (fp) into two parts, (hi, lo), assuring
      `fp === hi + lo`, `hi === fp - lo`, `lo === fp - hi`, and
      `ulp(abs(hi)) > ufp(abs(lo))`.

      ulp, ufp are acronyms for u[nit in the] {l[ast], f[irst]} p[lace]

      ulp(fp) = eps(fp)/2
      ufp(fp) = ldexp(0.5, exponent(fp)

   ref
       A floating-point technique for extending the available precision.
       T. J. Dekker.
       Numer. Math., 18:224–242, 1971
=#

# the 'factor' (2^s + 1)
#=
julia> p(::Type{Float64}) = round(Int64, -log2(ulp(Float64)))
p (generic function with 3 methods)

julia> one(Int64)+Int64(2)^cld(p(Float64),2),one(Int32)+Int32(2)^cld(p(Float32),2),one(Int16)+Int16(2)^cld(p(Float16),2)
(134217729, 4097, 65)
=#

# isplitter(::Type{Float128}) = one(Int128) << cld(113,2) + 1
isplitter(::Type{Float64}) = one(Int64) + one(Int64) << (cld(precision(Float64),2)-1)
isplitter(::Type{Float32}) = one(Int32) + one(Int32) << (cld(precision(Float32),2)-1)
isplitter(::Type{Float16}) = one(Int16) + one(Int16) << (cld(precision(Float16),2)-1)


splitter(::Type{Float64}) = Float64(isplitter(Float64))
splitter(::Type{Float32}) = Float32(isplitter(Float32))
splitter(::Type{Float16}) = Float16(isplitter(Float16))

# Dekker Veldkamp splitting of a floating point value
@inline function split_dv(x::T) where T<:Base.IEEEFloat
    absx = abs(x)
    z   = absx * splitter(T)
    !isfinite(z)   && throw(OverflowError("overflow using $x"))
    issubnormal(z) && throw(OverflowError("underflow using $x"))
    
    zₕᵢ = z - (z - absx)
    zₗₒ = absx - zₕᵢ
    return flipsign(zₕᵢ, x), flipsign(zₗₒ, x)
end

