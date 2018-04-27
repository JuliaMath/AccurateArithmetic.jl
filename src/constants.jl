four(::Type{Float64}) = 4.0
four(::Type{Float32}) = 4.0f0
four(::Type{Float16}) = Float16(4.0f0)

two(::Type{Float64}) = 2.0
two(::Type{Float32}) = 2.0f0
two(::Type{Float16}) = Float16(2.0f0)

negone(::Type{Float64}) = -1.0
negone(::Type{Float32}) = -1.0f0
negone(::Type{Float16}) = Float16(-1.0f0)

onehalf(::Type{Float64}) = 0.5
onehalf(::Type{Float32}) = 0.5f0
onehalf(::Type{Float16}) = Float16(0.5f0)

onequarter(::Type{Float64}) = 0.25
onequarter(::Type{Float32}) = 0.25f0
onequarter(::Type{Float16}) = Float16(0.25f0)
