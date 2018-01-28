# AccurateArithmetic.jl

### Floating point math with error-free, faithful, and compensated transforms. 

-------
&nbsp;

These arithmetic functions calculate results with extended precision significands.
They are used as building blocks for extended precision floating point types.

## Exports

Each exported function is named with the postfix "\_acc" (accurate).

The functions `add_hilo_acc` and `sub_hilo_acc` expect their arguments in order of decreasing magnitude.  This is an __unchecked__ precondition.


| function     | transformation |
|:-------------|---------------:|
|              |                |
| add_acc      | two_sum        |
| add_hilo_acc | quick_two_sum  |
|              |                |
| sub_acc      | two_diff       |
| sub_hilo_acc | quick_two_diff |
|              |                |
| mul_acc      | two_prod (FMA) |
|              |                |
| inv_acc      | reciprocal (FMA) |
| div_acc      | two_div  (FMA) |

&nbsp;

| function     | mapping        |
|:-------------|---------------:|
|              |                |
| sqr_acc      | hi(x^2), lo(x^2) |
| cub_acc      | hi(x^3), lo(x^3) |
|              |                |
| inv_acc      | hi(1/x), lo(1/x) |
| sqrt_acc     | hi(1/x^2), lo(1/x^2) |
|              |                |
| fma_acc      | hi(fma), mid(fma), lo(fma) |
| fms_acc      | hi(fms), mid(fms), lo(fms) |
|              |                |
| sum_acc      | error-free compensated |

&nbsp;

-----
    

| this package is under development |
|-----------------------------------|
| repository created on 2018-01-26  |
| tests pass on 2018-01-27          |
