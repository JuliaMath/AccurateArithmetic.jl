# AccurateArithmetic.jl

### Calculate with error-free, faithful, and compensated transforms and extended signficands. 

-------
&nbsp;

These arithmetic functions provide the usual floating point arithmetic result itself and additionally provide the lower order part from the calculation as if performed using an extended precision type. These more accurate forms of addition, subtraction, square, multiplication, reciprocation, division, and square-root accept the same two arguments as the usual arithmetic floating point ops.  They return a 2-tuple with the usual result first and the value of the precision extended significand second.

&nbsp;

-----
    

| this package is under development |
|-----------------------------------|
| repository created on 2018-01-26  |
| tests pass on 2018-01-27          |
