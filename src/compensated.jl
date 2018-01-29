function sum_hilo(x::A) where {T, N, A<:AbstractArray{T,N}}
    n = length(x)
    if n < 2 
        iszero(n) && return zero(T)
        isone(n)  && return x[1]
    end
    return do_sum_hilo(n, x)
end

function do_sum_hilo(n::Int, x::A) where {T, N, A<:AbstractArray{T,N}}
   hi = x[1]
   lo = zero(T)
   for i in 2:n
       hi, low = add_acc(hi, x[i])
       lo += low
   end
   hi, lo = add_hilo_acc(hi, lo)
   return hi, lo
end


       
   
   
