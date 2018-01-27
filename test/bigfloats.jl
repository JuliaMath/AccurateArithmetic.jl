# use BigFloats to determine the correct multipart significand values

setprecision(BigFloat, 1024-32)


function randbf(n::Int, minpow2::Int=-30, maxpow2::Int=30)
    pow2s = rand(minpow2:maxpow2, n)
    bfs = rand(BigFloat, n)
    bfls = [ldexp(frexp(bfs[i])[1], pow2s[i]) for i=1:n]
    return bfls
end

randfl(::Type{T}, n::Int, minpow2::Int=-30, maxpow2::Int=30)  where {T<:AbstractFloat} =
    map(T, randbf(n, minpow, maxpow2))   

srand(1602)
const nrands = 16
const fl64s = randfl(Float64, nrands)
const fl32s = randfl(Float32, nrands)

const Floats1 = NTuple{1,T} where {T<:AbstractFloat}
const Floats2 = NTuple{2,T} where {T<:AbstractFloat}
const Floats3 = NTuple{3,T} where {T<:AbstractFloat}
const Floats4 = NTuple{4,T} where {T<:AbstractFloat}
const Floats5 = NTuple{5,T} where {T<:AbstractFloat}
const Floats6 = NTuple{6,T} where {T<:AbstractFloat}
const Floats7 = NTuple{7,T} where {T<:AbstractFloat}
const Floats8 = NTuple{8,T} where {T<:AbstractFloat}
const Floats9 = NTuple{9,T} where {T<:AbstractFloat}


function Floats1(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   return (fl1, )
end

function Floats2(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   return fl1, fl2
end

function Floats3(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   return fl1, fl2, fl3
end

function Floats4(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   fl4 = T(bf - fl1 - fl2 - fl3)
   return fl1, fl2, fl3, fl4
end

function Floats5(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   fl4 = T(bf - fl1 - fl2 - fl3)
   fl5 = T(bf - fl1 - fl2 - fl3 - fl4)
   return fl1, fl2, fl3, fl4, fl5
end

function Floats6(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   fl4 = T(bf - fl1 - fl2 - fl3)
   fl5 = T(bf - fl1 - fl2 - fl3 - fl4)
   fl6 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5)
   return fl1, fl2, fl3, fl4, fl5, fl6
end

function Floats7(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   fl4 = T(bf - fl1 - fl2 - fl3)
   fl5 = T(bf - fl1 - fl2 - fl3 - fl4)
   fl6 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5)
   fl7 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5 - fl6)
   return fl1, fl2, fl3, fl4, fl5, fl6, fl7
end

function Floats8(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   fl4 = T(bf - fl1 - fl2 - fl3)
   fl5 = T(bf - fl1 - fl2 - fl3 - fl4)
   fl6 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5)
   fl7 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5 - fl6)
   fl8 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5 - fl6 - fl7)
   return fl1, fl2, fl3, fl4, fl5, fl6, fl7, fl8
end

function Floats9(::Type{T}, bf::BigFloat) where {T<:AbstractFloat}
   fl1 = T(bf)
   fl2 = T(bf - fl1)
   fl3 = T(bf - fl1 - fl2)
   fl4 = T(bf - fl1 - fl2 - fl3)
   fl5 = T(bf - fl1 - fl2 - fl3 - fl4)
   fl6 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5)
   fl7 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5 - fl6)
   fl8 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5 - fl6 - fl7)
   fl9 = T(bf - fl1 - fl2 - fl3 - fl4 - fl5 - fl6 - fl7 - fl8)
   return fl1, fl2, fl3, fl4, fl5, fl6, fl7, fl8, fl9
end
