# AccurateArithmetic.jl
### building blocks for more accurate floating point results

## Introduction

This package exports state of the art implementations of errorfree transformations, faithfully compensating constructs, and other error minimizing arithmetic functions.

The errorfree transformations (add_acc, sub_acc, sqr_acc, mul_acc), and their error minimizing cousins (inv_acc, div_acc, sqrt_acc) return both the usual floating point result and an additional value, an additive adjustment to the usual result.

Here is how we multiply two floating point values with greater accuracy.    
`xy_result` and `xy_adjust` are free of error, by construction.

```julia
julia> function mul_acc(x::F, y::F) where F<:AbstractFloat
           result = x * y
           adjust = fma(x, y, -result)
           return result, adjust
       end
mul_acc (generic function with 1 method)

julia> x, y = sqrt(2.0), log(2.0)
(1.4142135623730951, 0.6931471805599453)

julia> xy = x * y
0.9802581434685472

julia> xy_bfloat = BigFloat(x) * BigFloat(y);

julia> xy_result = Float64(xy_bfloat)
0.9802581434685472

julia> xy_adjust = Float64(xy_bfloat - xy_result)
-1.3243553298414006e-18

julia> xy_result == xy
true

julia> result, adjust = mul_acc(x, y)
(0.9802581434685472, -1.3243553298414006e-18)

julia> result == xy_result
true

julia> adjust == xy_adjust
true
```


