using Compat
using Compat.Test
using AccurateArithmetic

srand(1602)
include("bigfloats.jl")

const nrands = 16
const bflts = randbf(nrands)
const fl64s = randfl(Float64, nrands)
const fl32s = randfl(Float32, nrands)

hi64, lo64 = Floats2(Float64, bflts[1])
hi32, lo32 = Floats2(Float32, bflts[2])

@test add_acc(hi64, lo64) == (hi64, lo64)
@test add_hilo_acc(hi32, lo32) == (hi32, lo32)

hi64, lo64 = Floats2(Float64, bflts[3])
hi32, lo32 = Floats2(Float32, bflts[4])

@test mul_acc(hi64, lo64) == Floats2(Float64, BigFloat(hi64)*BigFloat(lo64))
@test div_acc(hi32, lo32) == Floats2(Float32, BigFloat(hi32)/BigFloat(lo32))

@test sqrt_acc(hi64) == Floats2(Float64, sqrt(BigFloat(hi64)))
@test inv_acc(hi32)  == Floats2(Float32, inv(BigFloat(hi32)))
