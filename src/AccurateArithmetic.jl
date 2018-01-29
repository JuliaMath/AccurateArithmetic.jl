module AccurateArithmetic

export add_acc, add_hilo_acc,
       sub_acc, sub_hilo_acc,
       sqr_acc, sqrt_acc, cub_acc,
       mul_acc, mul3acc,
       inv_acc, div_acc,
       fma_acc, fms_acc, 
       sum_acc,

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end

include("errorfree.jl")
include("faithful.jl")
include("compensated/sum.jl")

end # module AccurateArithmetic
