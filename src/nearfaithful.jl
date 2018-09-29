#= root3
function root3_2(x::T) where {T<:AbstractFloat}
    hi = cbrt(x)
    chi, clo = powr3_2(hi)
    d = (-chi + x) - clo
    lo = d / (T(3)*hi*hi)
    return hi, lo
end

@inline root3_(x::T) where {T<:AbstractFloat} = root3_2(x)
=#
