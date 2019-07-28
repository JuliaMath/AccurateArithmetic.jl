module Test
export generate_dot, generate_sum

using LinearAlgebra, Random
using AccurateArithmetic: two_prod

"""
    (x, y, d, c) = generate_dot(n, c)

Generate two Float64 vectors whose dot product is ill-conditioned.

Inputs:
  n -- vectors size
  c -- target condition number

Results:
  x, y -- vectors of size n
  d    -- accurate dot product, rounded to nearest
  c    -- actual condition number of the dot product
"""
function generate_dot(n, c)
    R = Rational{BigInt}

    # Initialization
    x = zeros(Float64, n)
    y = zeros(Float64, n)

    # First half of the vectors:
    #   random numbers within a large exponent range
    n2 = div(n, 2)
    b = log2(c)

    e = rand(n2) .* b/2
    e[1]  = b/2 + 1           # Make sure exponents b/2
    e[n2] = 0                 # and 0 actually occur
    for i in 1:n2
        x[i] = (2*rand()-1) * 2^(e[i])
        y[i] = (2*rand()-1) * 2^(e[i])
    end


    # Second half of the vectors such that
    #   (*) log2( dot (x[1:i], y[1:i]) ) decreases from b/2 to 0
    δe = -b/(2*(n-n2-1))
    e = b/2:δe:0
    for i in eachindex(e)
        # Random x[i]
        cx = (2*rand()-1) * 2^(e[i])
        x[i+n2] = cx

        # y[i] chosen according to (*)
        cy = (2*rand()-1) * 2^(e[i])
        y[i+n2] = (cy - Float64(dot(R.(x), R.(y)))) / cx
    end


    # Random permutation of x and y
    perm = randperm(n)
    X = x[perm]
    Y = y[perm]

    # Dot product, rounded to nearest
    d = Float64(dot(R.(X), R.(Y)))

    # Actual condition number
    c = 2 * dot(abs.(X), abs.(Y)) / abs(d)

    (X,Y,d,c)
end


"""
    (x, s, c) = generate_sum(n, c)

Generate a Float64 vectors whose sum is ill-conditioned.

Inputs:
  n -- vectors size
  c -- target condition number

Results:
  x -- vectors of size n
  s -- accurate sum, rounded to nearest
  c -- actual condition number of the sum
"""
function generate_sum(n, c)
    R = Rational{BigInt}

    (x, y, _, _) = generate_dot(n, c)
    z = (two_prod.(x, y)
         |> Iterators.flatten
         |> collect
         |> shuffle)

    # Sum, rounded to nearest
    s = Float64(sum(R.(z)))

    # Actual condition number
    c = sum(abs.(z)) / abs(s)

    (z, s, c)
end

end
