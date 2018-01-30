module AccurateArithmetic

export add, add_hilo,
       sub, sub_hilo,
       sqr, sqrt, cub,
       mul_3, mul,
       acc_inv, acc_div,
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
