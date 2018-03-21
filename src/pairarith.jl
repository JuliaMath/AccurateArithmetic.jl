function Base.:(+)(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
       hi, lo = two_sum(x[1], y[1])
       lohi, lolo = two_sum(x[2], y[2])
       lohi += lo
       hi, lo = fast_two_sum(hi, lohi)
       lolo += lo
       hi, lo = fast_two_sum(hi, lolo)
       return hi, lo
end

function Base.:(-)(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
       hi, lo = two_diff(x[1], y[1])
       lohi, lolo = two_diff(x[2], y[2])
       lohi += lo
       hi, lo = fast_two_sum(hi, lohi)
       lolo += lo
       hi, lo = fast_two_sum(hi, lolo)
       return hi, lo
end

function Base.:(*)(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    lo = two_prod(x[2], y[2])
    hi = two_prod(x[1], y[2])
    hilo = lo + hi
    hi = two_prod(x[2], y[1])
    hilo = hilo + hi
    hi = two_prod(x[1], y[1])
    hilo = hilo + hi
    return hilo
end
