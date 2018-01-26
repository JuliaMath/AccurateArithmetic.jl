# AccurateArithmetic.jl
### building blocks for more accurate floating point results

## Introduction

This package provides state of the art implementations of error-reducing arithmetic transformations.  Some are error-free (ideal ± ½bit), some faithful (ideal ± 1bit),
and for some the error-minimized calc is faithful-adjacent (ideal ± 2bits).

> `function` is the exported name

> `in` is the number of arguments given to the function    
> `out` is the number of values returned by the function

> `preconditions` are **unchecked**

| function | ... | preconditions  | transformation | in  | out |
|----------|:---:|:--------------:|:--------------:|:---:|:---:|
| add      |     | none           | error-free     | 2   | 2   |
| add_hilo |     | ` \|x\|≥\|y\|` | error-free     | 2   | 2   |
| sub      |     | none           | error-free     | 2   | 2   |
| sub_hilo |     | ` \|x\|≥\|y\|` | error-free     | 2   | 2   |
| sub_lohi |     | ` \|x\|≥\|y\|` | error-free     | 2   | 2   |
| sqr      |     | none           | error-free     | 1   | 2   |
| mul      |     | none           | error-free     | 2   | 2   |
|          |     |                |                |     |     |
| inv      |     | none           | faithful       | 1   | 2   |
| sqrt     |     | none           | faithful       | 1   | 2   |
|          |     |                |                |     |     |
| div      |     | none           | faithful       | 2   | 2   |
|          |     |                |                |     |     |
| hypot    |     | none           | near-faithful  | 2   | 2   |




The error-free transformations (add_acc, sub_acc, sqr_acc, mul_acc), and error-faithful tranformations (inv_acc, sqrt_acc), and error-minimal transformations (div_acc). Each function retursn a tuple containing the usual floating point result (`hi`, others use `s`) and an additive correction to the usual result (`lo`, others use `err`).    
* They are such that `hi + lo == hi` i.e. `abs(lo) <= eps(hi)/4`. 

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


