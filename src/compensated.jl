function sum_(x::A) where {T, N, A<:AbstractArray{T,N}}
    n = length(x)
    if n < 2
        iszero(n) && return zero(T)
        isone(n)  && return x[1]
    end
    return do_sum_(n, x)
end

function do_sum_(n::Int, x::A) where {T, N, A<:AbstractArray{T,N}}
   hi = x[1]
   lo = zero(T)
   for i in 2:n
       hi, low = add_acc(hi, x[i])
       lo += low
   end
   hi, lo = add_hilo(hi, lo)
   return hi, lo
end
