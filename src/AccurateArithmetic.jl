module AccurateArithmetic

export add_hilo, add_hilo_hilo,
       sub_hilo, sub_hilo_hilo,
       sqr_hilo, sqrt_hilo, cub_hilo,
       mul_hilo, mul3hilo,
       inv_hilo, div_hilo,
       fma_hilo, fms_hilo, 
       sum_hilo

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end

include("errorfree.jl")
include("faithful.jl")
include("compensated.jl")

end # module AccurateArithmetic
