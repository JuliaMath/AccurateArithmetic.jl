module AccurateArithmetic

export add_acc, add_hilo_acc,
       sub_acc, sub_hilo_acc,
       sqr_acc, cub_acc,
       sqrt_acc,
       mul_acc, mul_acc3,
       inv_acc, div_acc,
       fma_acc, fms_acc,
       sum_acc

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
    macro isdefined(x)
        :(isdefined(Symbol($x)))
    end
end

if @isdefined CONFIRM
   if !@isdefined confirm
       macro confirm(expr)
           :(@assert $expr)
       end
   end  
else
    macro confirm(expr) end
end

include("renormalize.jl")
include("errorfree.jl")
include("faithful.jl")
include("compensated.jl")

end # module AccurateArithmetic
