module EFT
export two_sum, fast_two_sum, two_prod

import ..SIMDops
using ..SIMDops: vabs, vfma, vifelse, vless

include("errorfree.jl")

end
