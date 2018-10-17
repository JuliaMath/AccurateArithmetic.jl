using AccurateArithmetic
using Test
using Random: seed!

using Base:IEEEFloat

seed!(1602)
include("bigfloats.jl")
include("randfloats.jl")

const nrands = 16
const flbig = randbf(nrands)
const fl64s = map(Float64, flbig)
const fl32s = map(Float32, flbig)

hi64, lo64 = Floats2(Float64, flbig[1])
hi32, lo32 = Floats2(Float32, flbig[2])

@test add_(lo64, hi64) == (hi64, lo64)
@test add_hilo_(hi32, lo32) == (hi32, lo32)

@test sub_(lo64, hi64) == Floats2(Float64, BigFloat(lo64) - BigFloat(hi64))
@test sub_hilo_(hi32, lo32) == Floats2(Float32, BigFloat(hi32) - BigFloat(lo32))

hi64, lo64 = Floats2(Float64, flbig[3])
hi32, lo32 = Floats2(Float32, flbig[4])

@test powr2_(hi64) == Floats2(Float64, BigFloat(hi64)^2)

@test mul_(hi64, lo64) == Floats2(Float64, BigFloat(hi64)*BigFloat(lo64))
@test dvi_(hi32, lo32) == Floats2(Float32, BigFloat(hi32)/BigFloat(lo32))

hi,lo=Floats2(Float64, sqrt(BigFloat(hi64)))
@test (root2_(hi64) == (hi, lo)) || (root2_(hi64) == (hi, prevfloat(lo))) || (root2_(hi64) == (hi, nextfloat(lo)))

hi,lo=Floats2(Float32, inv(BigFloat(hi32)))
@test (inv_(hi32)  == (hi,lo)) || (inv_(hi32) == (hi, prevfloat(lo))) || (inv_(hi32) == (hi, nextfloat(lo)))

hi64, md64, lo64 = Floats3(Float64, flbig[5])
hi32, md32, lo32 = Floats3(Float32, flbig[5])

@test mul_(hi64, lo64, md64) == Floats3(Float64, BigFloat(hi64) * BigFloat(lo64) * BigFloat(md64))
@test mul_(hi64, lo64, md64) == Floats3(Float64, BigFloat(hi64) * BigFloat(lo64) * BigFloat(md64))

@test fma_(hi64, lo64, md64) == Floats3(Float64, BigFloat(hi64) * BigFloat(lo64) + BigFloat(md64))
@test fms_(md32, lo32, hi32) == Floats3(Float32, BigFloat(md32) * BigFloat(lo32) - BigFloat(hi32))

flbig64s = map(BigFloat, fl64s)
@test sum_(fl64s) == Floats2(Float64, sum(flbig64s))
