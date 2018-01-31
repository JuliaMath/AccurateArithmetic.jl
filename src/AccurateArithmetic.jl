module AccurateArithmetic

#=
     These exported functions are named with a trailing underscore ('_').
     Evaluating as multipart values, the '_' indicates this extra accuracy.
=#

export add_, sub_, add_hilo_, sub_hilo_, 
       sqr_, cub_, mul_,
       fma_, fms_,
       sqrt_, inv_, div_,
       sum_ 


if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end


include("renormalize.jl")
include("errorfree.jl")
include("faithful.jl")
include("compensated.jl")

end # module AccurateArithmetic
