# for significands in [1, 2)
exponent_max(::Type{Float16})  =   15
exponent_max(::Type{Float32})  =  127
exponent_max(::Type{Float64})  = 1023
exponent_min(::Type{Float16})  = 1 -   15
exponent_min(::Type{Float32})  = 1 -  127
exponent_min(::Type{Float64})  = 1 - 1023

for (U,F) in ((:UInt64, :Float64), (:UInt32, :Float32), (:UInt16, :Float16))
    @eval begin
        function randf(::Type{$F})
            r = $F(Inf)
            while !isfinite(r)
                r = reinterpret($F, rand($U))
            end
            return r
        end
        function randfloat(::Type{$F}, n::Int, emin::Int=exponent_min($F), emax::Int=exponent_max($F), signed::Bool=false)
            emin, emax = minmax(emin, emax)
            emin = max(exponent_min($F), emin)
            emax = min(exponent_max($F), emax)
            n = max(1, n)
            result = Vector{$F}(uninitialized, n)
            for i in 1:n
                r = rand($F) + one($F) # significand in [1, 2)
                e = rand(emin:1:emax)
                result[i] = ldexp(r, e) 
            end
            if signed
               signs = rand(-1:2:1,n)
               for i in 1:n
                   result[i] = copysign(result[i], rand(-1:2:1))
               end
            end
            return result
        end
    end
end
