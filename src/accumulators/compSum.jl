mutable struct CompSumAcc{T, EFT}
    s :: T
    e :: T
end

@inline compSumAcc(EFT) = T->compSumAcc(EFT, T)
@inline compSumAcc(EFT, T) = CompSumAcc{T, EFT}(vzero(T), vzero(T))

@inline function add!(acc::CompSumAcc{T, EFT}, x::T) where {T, EFT}
    acc.s, e = EFT(acc.s, x)
    @fastmath acc.e += e
end

@inline function add!(acc::A, x::A) where {A<:CompSumAcc{T, EFT}} where {T, EFT}
    acc.s, e = EFT(acc.s, x.s)
    @fastmath acc.e += x.e + e
end

@inline function Base.sum(acc::CompSumAcc{T, EFT}) where {W, T<:Vec{W}, EFT}
    acc_r = compSumAcc(EFT, fptype(T))
    acc_r.e = vsum(acc.e)
    for w in 1:W
        acc_r.s, ei = EFT(acc_r.s, acc.s(w))
        acc_r.e += ei
    end
    acc_r
end

@inline function Base.sum(acc::CompSumAcc{T, EFT}) where {T<:Real, EFT}
    acc.s + acc.e
end
