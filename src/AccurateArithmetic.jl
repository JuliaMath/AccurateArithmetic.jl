module AccurateArithmetic

export add_acc, add_hilo_acc, add₊, add_hilo₊, 
       sub_acc, sub_hilo_acc, sub_lohi_acc, sub₊, sub_hilo₊, sun_lohi₊,
       sqr_acc, mul_acc, cub_acc, sqr₊, mul₊, cub₊,
       inv_acc, div_acc, inv₊, div₊,
       sqrt_acc, sqrt₊

import Base.IEEEFloat # Union{Float64, Float32, Float16}


include("errorfree/addsubmul.jl")


for (A, F) in ( (:add_acc, :(add₊)),  (:add_hilo_acc, :(add_hilo₊)),
                (:sub_acc, :(sub₊)),  (:sub_hilo_acc, :(sub_hilo₊)), (:sub_lohi_acc, :(sub_lohi₊)),
                (:sqr_acc, :(sqr₊)),  (:mul_acc, :(mul₊)), (:cub_acc, :(cub₊)),
                (:inv_acc, :(inv₊)),  (:div_acc, :(div₊)),
                (:sqrt_acc, :(sqrt₊)), )
   @eval begin
       const $F = $A
   end
end


end # module AccurateArithmetic
