@inline function two_sum(a::T, b::T) where T<:AbstractFloat
    ab =  a + b
    B  = ab - a
    ε  = (a - (ab - B)) + (b - B)
    return ab, ε
end

@inline function two_diff(a::T, b::T) where T<:AbstractFloat
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
@inline function fast_two_sum(a::T, b::T) where T<:AbstractFloat
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
@inline function fast_two_diff(a::T, b::T) where T<:AbstractFloat 
     ab =  a - b
     B  = ab - a
     ε  =  B - b
     return ab, ε
end

@inline function two_prod(a::T, b::T) where T<:AbstractFloat
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

splitter(::Type{Float64}) =
    Float64(one(Int64) + one(Int64) << (cld(precision(Float64),2)-1))
splitter(::Type{Float32}) = 
    Float32(one(Int32) + one(Int32) << (cld(precision(Float32),2)-1))
splitter(::Type{Float16}) = 
    Float16(one(Int16) + one(Int16) << (cld(precision(Float16),2)-1))

splitmax(::Type{Float64}) = realmax(Float64) / splitter(Float64)
splitmax(::Type{Float32}) = realmax(Float32) / splitter(Float32)
splitmax(::Type{Float16}) = realmax(Float16) / splitter(Float16)

# Veldkamp splitting of a floating point value
@inline function splitting(x::T) where T<:AbstractFloat
    (!isfinite(x) || abs(x) > splitmax(T)) && throw(OverflowError("$x overflows"))
    z   = x * splitter(T)
    zₕᵢ = z - (z - x)
    zₗₒ = x - zₕᵢ
    return zₕᵢ, zₗₒ
end

# Rump splitting
#    In extractscalar, a floating-point number fp is split relative to p2,
#    a fixed power of 2.
function extractscalar(fp, p2=2^27)
    hi = (p2 + fp) - p2
    lo = fp - hi
    return hi, lo
end

#=
    splitfp(fp) =?= extractscalar(2^(?+exponent(fp)), fp)

=#

for (U,F) in ((:UInt64, :Float64), (:UInt32, :Float32), (:UInt16, :Float16))
  @eval begin
    @inline function ufp(x::$F)
        u = reinterpret($U, x)
        u = (u >> (precision($F)-1)) << (precision($F)-1)
        return reinterpret($F, u)
    end
  end
end

const Float64ulp = inv(ldexp(1.0, precision(Float64)))
const Float32ulp = inv(ldexp(1.0, precision(Float32)))
const Float16ulp = inv(ldexp(1.0, precision(Float16)))

@inline ulp(x::Float64) = ufp(x) * Float64ulp
@inline ulp(x::Float32) = ufp(x) * Float32ulp
@inline ulp(x::Float16) = ufp(x) * Float16ulp

const Float64eps = inv(ldexp(1.0, precision(Float64)-1))
const Float32eps = inv(ldexp(1.0, precision(Float32)-1))
const Float16eps = inv(ldexp(1.0, precision(Float16)-1))

@inline epsi(x::Float64) = ufp(x) * Float64eps
@inline epsi(x::Float32) = ufp(x) * Float32eps
@inline epsi(x::Float16) = ufp(x) * Float16eps
