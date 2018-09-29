module AccurateArithmetic


export
       four, two, negone, onehalf, onequarter, 
       fourx, twox, halfx, quarterx,
#=
       These functions appear in the literature, named similarly.
=#
       two_sum, two_diff, two_prod, 
       fast_two_sum, fast_two_diff,
       ufp, ulp, splitting, extractscalar,
#=
     These functions evaluate as multipart floats.
     The trailing '_' signifies this extra accuracy.
=#
       add_, sub_, add_hilo_, sub_hilo_, 
       mul_, inv_, dvi_,
       powr2_, root2_, # powr3_, root3_,
       sum_,
       add_2, add_3, add_4, add_5,
       add_hilo_2, add_hilo_3, add_hilo_4, add_hilo_5,
       sub_2, sub_3,
       sub_hilo_2, sub_hilo_3,
       powr2_2, #powr3_2, powr3_3,
       root2_2, #root3_2, 
       mul_2, mul_3,
       inv_2, dvi_2,
       fma_, fma_3, fma_2, fms_, fms_3, fms_2


if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end

import Base: signbit, flipsign, copysign, abs, inv, (+), (-), (*), (/)

include("constants.jl")
include("twoarith.jl")
include("renormalize.jl")
include("errorfree.jl")
include("faithful.jl")
include("nearfaithful.jl")
include("compensated.jl")
include("pairarith.jl")

end # module AccurateAritmetic
