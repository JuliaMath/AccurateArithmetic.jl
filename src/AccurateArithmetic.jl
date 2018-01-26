module AccurateArithmetic

export add_acc, add_acc_hilo, add₊, add_hilo₊, 
       sub_acc, sub_acc_hilo, sub_acc_lohi, sub₊, sub_hilo₊, sun_lohi₊,
       sqr_acc, mul_acc, sqr₊, mul₊,
       inv_acc, div_acc, inv₊, div₊,
       sqrt_acc, sqrt₊

import Base.IEEEFloat # Union{Float64, Float32, Float16}

for (A, F) in ( (:add_acc, :(add₊)),  (:add_acc_hilo, :(add_hilo₊)),
                (:sub_acc, :(sub₊)),  (:sub_acc_hilo, :(sub_hilo₊)), (:sub_acc_lohi, :(sub_lohi₊)),
                (:sqr_acc, :(sqr₊)),  (:mul_acc, :(mul₊)),
                (:inv_acc, :(inv₊)),  (:div_acc, :(div₊)),
                (:sqrt_acc, :(sqrt₊)), )
   @eval begin
       const $F = $A
   end
end


end # module AccurateArithmetic
