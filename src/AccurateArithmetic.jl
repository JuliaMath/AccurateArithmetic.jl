module AccurateArithmetic

export add_acc, add₊, sub_acc, sub₊,
       add_hilo_acc, add_hilo₊, 
       sub_hilo_acc, sub_hilo₊, sub_lohi_acc, sub_lohi₊,
       sqr_acc, sqr₊, mul_acc, mul₊, cub_acc, cub₊,
       inv_acc, inv₊, div_acc, div₊,
       sqrt_acc, sqrt₊

import Base.IEEEFloat # Union{Float64, Float32, Float16}


include("errorfree/addsubmul.jl")
include("faithful/divsqrt.jl")


for (A, F) in ( (:add_acc, :(add₊)),  (:add_hilo_acc, :(add_hilo₊)),
                (:sub_acc, :(sub₊)),  (:sub_hilo_acc, :(sub_hilo₊)), (:sub_lohi_acc, :(sub_lohi₊)),
                (:sqr_acc, :(sqr₊)),  (:mul_acc, :(mul₊)), (:cub_acc, :(cub₊)),
                (:inv_acc, :(inv₊)),  (:div_acc, :(div₊)),
                (:sqrt_acc, :(sqrt₊)), )
   @eval begin
       const $A = $F
   end
end


end # module AccurateArithmetic
