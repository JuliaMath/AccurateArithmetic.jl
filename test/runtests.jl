using Compat
using Compat.Test
using AccurateArithmetic

if VERSION >= v"0.7.0-"
  using Random
end

srand(1602)
include("bigfloats.jl")

const nrands = 16
const flbig = randbf(nrands)
const fl64s = randfl(Float64, nrands)
const fl32s = randfl(Float32, nrands)

hi64, lo64 = Floats2(Float64, flbig[1])
hi32, lo32 = Floats2(Float32, flbig[2])

@test add_acc(hi64, lo64) == (hi64, lo64)
@test add_hilo_acc(hi32, lo32) == (hi32, lo32)

hi64, lo64 = Floats2(Float64, flbig[3])
hi32, lo32 = Floats2(Float32, flbig[4])
hi, md, lo = Floats3(Float64, flbig[5])

@test sqr_acc(hi64) == Floats2(Float64, BigFloat(hi64)^2)
@test cub_acc(hi32) == Floats2(Float32, BigFloat(hi32)^3)

@test mul_acc(hi64, lo64) == Floats2(Float64, BigFloat(hi64)*BigFloat(lo64))
@test div_acc(hi32, lo32) == Floats2(Float32, BigFloat(hi32)/BigFloat(lo32))

@test sqrt_acc(hi64) == Floats2(Float64, sqrt(BigFloat(hi64)))
@test inv_acc(hi32)  == Floats2(Float32, inv(BigFloat(hi32)))

@test fma_acc(hi, lo, md) == Floats3(BigFloat(hi) * BigFloat(lo) + BigFloat(md))
@test fms_acc(md, lo, hi) == Floats3(BigFloat(md) * BigFloat(lo) + BigFloat(hi))

@test sum_acc(fl64s) == Floats2(sum(flbig))
