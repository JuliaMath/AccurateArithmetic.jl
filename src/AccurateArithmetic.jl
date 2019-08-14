module AccurateArithmetic


include("SIMDops.jl")


include("EFT.jl")
using .EFT
export two_sum, two_prod


include("Summation.jl")
using .Summation
export sum_naive, sum_kbn, sum_oro
export dot_naive, dot_oro


include("Test.jl")


end # module
