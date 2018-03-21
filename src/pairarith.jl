@inline function signbit(x::Tuple{T,T}) where T<:AbstractFloat
    return signbit(x[1])
end

@inline function (-)(x::Tuple{T,T}) where T<:AbstractFloat
    return -x[1], -x[2]
end

@inline function abs(x::Tuple{T,T}) where T<:AbstractFloat
    return signbit(x[1]) ? -x : x
end

@inline function flipsign(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    return signbit(y[1]) ? -x : x
end

@inline function copysign(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    return signbit(y[1]) ? -abs(x) : abs(x)
end

function (+)(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    hi, lo = two_sum(x[1], y[1])
    lohi, lolo = two_sum(x[2], y[2])
    lohi += lo
    hi, lo = fast_two_sum(hi, lohi)
    lolo += lo
    hi, lo = fast_two_sum(hi, lolo)
    return hi, lo
end

function (-)(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    hi, lo = two_diff(x[1], y[1])
    lohi, lolo = two_diff(x[2], y[2])
    lohi += lo
    hi, lo = fast_two_sum(hi, lohi)
    lolo += lo
    hi, lo = fast_two_sum(hi, lolo)
    return hi, lo
end

function (*)(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    lo = two_prod(x[2], y[2])
    hi = two_prod(x[1], y[2])
    hilo = lo + hi
    hi = two_prod(x[2], y[1])
    hilo = hilo + hi
    hi = two_prod(x[1], y[1])
    hilo = hilo + hi
    return hilo
end
