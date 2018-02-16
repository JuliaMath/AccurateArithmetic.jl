# AccurateArithmetic.jl

### Floating point math with error-free, faithful, and compensated transforms. 

-------
&nbsp;

These arithmetic functions calculate results with extended precision significands.    
They are used as building blocks for extended precision floating point types.

## Exports

The exported functions that are named with the postfixes `_2`, `_3` &etc
are functions that *return* 2 values or 3 values (respectively). The exported functions that are named with the postfix `_` are functions that return the same number of values as it is given arguments.  These are easier to use where the number of components to an extended precision value may vary. And they are more succinct where that is useful.

The functions `add_hilo_acc` and `sub_hilo_acc` expect their arguments in order of decreasing magnitude.  This is an __unchecked__ precondition.


| function     | n args in      | n values out | transformation |
|:-------------|---------------:|:------------:|:---------------|
|              |                |              |                |
| add_         | 2,3,4,5        | n args in    | two_sum        |
|              |                |              |                |
| add_2        | 2,3,4,5        | 2            | two_sum        |
| add_3        | 3,4,5          | 3            | two_sum        |
| add_4        | 4,5            | 4            | two_sum        |
| add_5        | 5              | 5            | two_sum        |
|              |                |              |                |
| add_hilo_    | 2,3,4,5        | n args in    | two_sum        |
|              |                |              |                |
| add_hilo_2   | 2,3,4,5        | 2            | quick_two_sum  |
| add_hilo_3   | 3,4,5          | 3            | quick_two_sum  |
| add_hilo_4   | 4,5            | 4            | quick_two_sum  |
| add_hilo_5   | 5              | 5            | quick_two_sum  |
|              |                |              |                |
| sub_         | 2,3            | n args in    | two_diff       |
|              |                |              |                |
| sub_2        | 2,3            | 2            | two_diff       |
| sub_3        | 3              | 3            | two_diff       |
|              |                |              |                |
| sub_hilo_    | 2,3            | n args in    | quick_two_diff |
|              |                |              |                |
| sub_hilo_2   | 2,3            | 2            | quick_two_diff |
| sub_hilo_3   | 3              | 3            | quick_two_diff |
|              |                |              |                |
| mul_         | 2,3            | n args in    | two_prod_fma   |
|              |                |              |                |
| mul_2        | 2,3            | 2            | two_prod_fma   |
| mul_3        | 3              | 3            | two_prod_fma   |
|              |                |              |                |
| sqrt_        | 1              | 2            | faithful sqrt  |
| inv_         | 1              | 2            | faithful divide |
| dvi_         | 2              | 2            | faithful divide |
|              |                |              |                |
| sqrt_2       | 1              | 2            | faithful sqrt  |
| inv_2        | 1              | 2            | faithful divide |
| dvi_2        | 2              | 2            | faithful divide |

- note that *divide* is abbreviated *dvi* (to distinguish it from *div*)


&nbsp;

| function     | mapping        |
|:-------------|---------------:|
|              |                |
| sqr_2        | hi(x^2), lo(x^2) |
| cub_2        | hi(x^3), lo(x^3) |
|              |                |
| fma_         | hi(fma), mid(fma), lo(fma) |
| fms_         | hi(fms), mid(fms), lo(fms) |
|              |                |
| sum_         | error-free compensated |

&nbsp;

-----
    

| this package is under development |
|-----------------------------------|
| repository created on 2018-01-26  |
| tests pass on 2018-01-27          |
