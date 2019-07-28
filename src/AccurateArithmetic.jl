module AccurateArithmetic

import VectorizationBase
using SIMDPirates: Vec, evadd, evsub, vifelse, vabs, vload, vsum, vbroadcast, vless

include("errorfree.jl")


# T. J. Dekker. "A Floating-Point Technique for Extending the Available Precision". 1971
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
    Pirate.@explicit

    x = a + b

    t = vless(vabs(a), vabs(b))
    a_ = vifelse(t, b, a)
    b_ = vifelse(t, a, b)

    z = x - a_
    e = b_ - z

    x, e
end


export sum_kbn, sum_oro
include("summation.jl")


include("Test.jl")

end # module
