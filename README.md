# AccurateArithmetic.jl

### Floating point math with error-free, faithful, and compensated transforms. 

-------
&nbsp;

These arithmetic functions calculate results with extended precision significands.
They are used as building blocks for extended precision floating point types.

## Exports

Each exported function is named with the postfix "\_acc" (accurate).

The functions `add_hilo_acc` and `sub_hilo_acc` expect their arguments in order of decreasing magnitude.  This is an __unchecked__ precondition.



| function | args | implements |
|---------|-------|----------|
| add_acc | 2     | two_sum  |
| add_acc | 3,4   |          |
| sub_acc | 2     | two_diff |
| sub_acc | 3     |          |
| mul_acc | 2     | two_prod (FMA) |
| div_acc | 2     |          |

&nbsp;

| function | args | implements |
|---------|-------|----------|
|         |       |          |
| sqr_acc | 1     |          |
| cub_acc | 1     |          |
| inv_acc | 1     |          |
| sqrt_acc | 1    |          |
|         |       |          |
| fma_acc |  3    |          |
| fms_acc |  3    |          |
|         |       |          |
| sum_acc | 1     |           |

&nbsp;

-----
    

| this package is under development |
|-----------------------------------|
| repository created on 2018-01-26  |
| tests pass on 2018-01-27          |
