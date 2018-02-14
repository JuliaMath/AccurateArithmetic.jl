function sum_2(x::A) where {T, N, A<:AbstractArray{T,N}}
    n = length(x)
    if n < 2
        iszero(n) && return zero(T)
        isone(n)  && return x[1]
    end
    return summation_(n, x)
end

@inline sum_(x::A) where {T, N, A<:AbstractArray{T,N}} = sum_2(x)

function summation_(n::Int, x::A) where {T, N, A<:AbstractArray{T,N}}
   hi = x[1]
   lo = zero(T)
   for i in 2:n
       hi, low = add_(hi, x[i])
       lo += low
   end
   hi, lo = add_hilo_(hi, lo)
   return hi, lo
end
