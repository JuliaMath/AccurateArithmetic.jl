# AccurateArithmetic.jl
### building blocks for more accurate floating point results

## Introduction

This package provides error-reducing arithmetic transformations.    
Some are error-free (ideal ± ½bit), some faithful (ideal ± 1bit),   
others' error-minimized calc is faithful-adjacent (ideal ± 2bits),    
or roughly-accurate (ideal ± 3bits).

If the ideal Float64 result is `ideal`, error-free calcs yield `ideal`.

Faithful calcs yield these:    
- `prevfloat(ideal)`, `ideal`, `nextfloat(ideal)`.     

Faithful adjacents yield values in the span:    
- `ideal - eps(ideal)/2` .. `ideal` .. `ideal + eps(ideal)/2`

Roughy accurates yield values in the span:    
- `ideal - eps(ideal)*2` .. `ideal` .. `ideal + eps(ideal)*2`

&nbsp;
------------
&nbsp;

&nbsp; &nbsp; &nbsp; each function has two names:&nbsp; 
`func_acc` and `func₊` ("func\_+<tab>")
&nbsp;
           
           
&nbsp;

| function  | ASCII name | preconditions  | transformation | in  | out |
|-----------|:----------|:--------------:|:--------------:|:---:|:---:|
| add₊      | add_acc    | none           | error-free     | 2   | 2   |
| add_hilo₊ | add_hilo_acc    | ` \|x\|≥\|y\|` | error-free     | 2   | 2   |
| sub₊      | sub_acc    | none           | error-free     | 2   | 2   |
| sub_hilo₊ | sub_hilo_acc    | ` \|x\|≥\|y\|` | error-free     | 2   | 2   |
| sub_lohi₊ | sub_lohi_acc    | ` \|x\|≥\|y\|` | error-free     | 2   | 2   |
| sqr₊      | sqr_acc    | none           | error-free     | 1   | 2   |
| mul₊      | mul_acc    | none           | error-free     | 2   | 2   |
|           |     |                |                |     |     |
| inv₊      | inv_acc     | none           | faithful       | 1   | 2   |
| sqrt₊     | sqrt_acc    | none           | faithful       | 1   | 2   |
|           |     |                |                |     |     |
| div₊      | div_acc    | none           | faithful       | 2   | 2   |
|           |     |                |                |     |     |
| hypot₊    | hypot_acc  | none           | near-faithful  | 2   | 2   |

&nbsp;
&nbsp;

| legend |
|---------|
| |
| `function` is the op name: name₊ and name_acc are synonyms |
| |
| `preconditions` are **unchecked** |
| |
| `in` is the number of arguments given to the function    |
| |
| `out` is the number of values returned by the function   |

&nbsp;
--------
&nbsp;


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


