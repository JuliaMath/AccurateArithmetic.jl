mutable struct CompSumAcc{T, EFT}
    s :: T
    e :: T
end

compSumAcc(EFT) = T->compSumAcc(EFT, T)
compSumAcc(EFT, T) = CompSumAcc{T, EFT}(zero(T), zero(T))

function add!(acc::CompSumAcc{T, EFT}, x::T) where {T, EFT}
    Pirate.@explicit

    acc.s, e = EFT(acc.s, x)
    acc.e += e
end

function add!(acc::A, x::A) where {A<:CompSumAcc{T, EFT}} where {T, EFT}
    Pirate.@explicit

    acc.s, e = EFT(acc.s, x.s)
    acc.e += x.e + e
end

function Base.sum(acc::CompSumAcc{T, EFT}) where {T<:Vec, EFT}
    acc_r = compSumAcc(EFT, fptype(T))
    acc_r.e = vsum(acc.e)
    for xi in acc.s
        acc_r.s, ei = EFT(acc_r.s, xi.value)
        acc_r.e += ei
    end
    acc_r
end

function Base.sum(acc::CompSumAcc{T, EFT}) where {T<:Real, EFT}
    acc.s + acc.e
end
