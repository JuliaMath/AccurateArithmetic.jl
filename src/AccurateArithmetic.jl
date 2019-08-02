module AccurateArithmetic

export two_sum, two_prod
export sum_naive, sum_kbn, sum_oro
export dot_naive, dot_oro

import VectorizationBase
import SIMDPirates
using SIMDPirates: Vec, vload, vabs, vless, vifelse, vsum, vfmsub

include("pirate.jl")
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


include("summation.jl")


include("Test.jl")

end # module
