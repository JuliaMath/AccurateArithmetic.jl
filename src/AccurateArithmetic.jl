module AccurateArithmetic

include("EFT.jl")
using .EFT
export two_sum, two_prod


include("Summation.jl")
using .Summation
export sum_naive, sum_kbn, sum_oro, sum_mixed
export dot_naive, dot_oro, dot_mixed


include("Test.jl")


end # module
