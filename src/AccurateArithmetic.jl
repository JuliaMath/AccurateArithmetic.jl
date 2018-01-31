module AccurateArithmetic


export
#=
       These functions appear in the literature, named similarly.
=#
       two_sum, two_diff, two_prod, 
       fast_two_sum, fast_two_diff,
#=
     These functions evaluate as multipart floats.
     The trailing '_' signifies this extra accuracy.
=#
       add_, sub_, add_hilo_, sub_hilo_, 
       sqr_, cub_, mul_,
       fma_, fms_,
       sqrt_, inv_, div_,
       sum_ 


if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end


include("twoarith.jl")
include("renormalize.jl")
include("errorfree.jl")
include("faithful.jl")
include("compensated.jl")

end # module AccurateArithmetic
