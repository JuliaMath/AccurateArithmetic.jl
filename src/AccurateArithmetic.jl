module AccurateArithmetic

export add_acc, add₊, add_hilo_acc, add_hilo₊,
       sub_acc, sub₊, sub_hilo_acc, sub_hilo₊,
       sqr_acc, sqr₊, cub_acc, cub₊, 
       mul_acc, mul₊, sqrt_acc, sqrt₊,
       inv_acc, inv₊, div_acc, div₊, 
       fma_acc, fma₊, fms_acc, fms₊, 
       sum_acc, sum₊


if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end


include("errorfree/addsubmul.jl")
include("faithful/divsqrt.jl")
include("compensated/sum.jl")


for (A, F) in ( (:add_acc, :(add₊)), (:add_hilo_acc, :(add_hilo₊)),
                (:sub_acc, :(sub₊)), (:sub_hilo_acc, :(sub_hilo₊)),
                (:sqr_acc, :(sqr₊)), (:cub_acc, :(cub₊)),
                (:mul_acc, :(mul₊)), (:sqrt_acc, :(sqrt₊)), 
                (:inv_acc, :(inv₊)), (:div_acc, :(div₊)),
                (:fma_acc, :(fma₊)), (:fms_acc, :(fms₊)),
                (:sum_acc, :(sum₊)), )
   @eval begin
       const $F = $A
   end
end


end # module AccurateArithmetic
