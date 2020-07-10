module Test
export generate_dot, generate_sum

using LinearAlgebra, Random
using ..EFT: two_prod

"""
    (x, y, d, c) = generate_dot(n, c)

Generate two Float64 vectors whose dot product is ill-conditioned.

Inputs:
  n   -- vectors size
  c   -- target condition number (must be >1)
  rng -- (pseudo-)random number generator

Results:
  x, y -- vectors of size n
  d    -- accurate dot product, rounded to nearest
  c    -- actual condition number of the dot product
"""
function generate_dot(n, c::T; rng=Random.GLOBAL_RNG) where {T}
    generate(c, 100, "dot product") do c1
        generate_dot_(n, T(c1), rng)
    end
end


"""
    (x, s, c) = generate_sum(n, c)

Generate a Float64 vectors whose sum is ill-conditioned.

Inputs:
  n   -- vectors size
  c   -- target condition number (must be >1)
  rng -- (pseudo-)random number generator

Results:
  x -- vector of size n
  s -- accurate sum, rounded to nearest
  c -- actual condition number of the sum
"""
function generate_sum(n, c::T; rng=Random.GLOBAL_RNG) where {T}
    generate(c, 10, "sum") do c1
        generate_sum_(n, T(c1), rng)
    end
end



function generate(f, c, cmin, title)
    c1 = c
    c = max(c, cmin)
    for i in 1:100
        res = f(c1)
        c_ = last(res)

        # println("$i -> $c1 \t $c_")

        if     c_ > 3*c
            c1 = max(1.01, 0.8*c1)
        elseif c_ < c/3
            c1 *= 1.1
        else
            return res
        end
    end
    @error "Could not generate $title with requested condition number"
end


function generate_dot_(n, c::T, rng) where {T}
    R = Rational{BigInt}

    # Initialization
    x = zeros(T, n)
    y = zeros(T, n)

    # First half of the vectors:
    #   random numbers within a large exponent range
    n2 = div(n, 2)
    b = log2(c)

    e = rand(rng, n2) .* b/2
    e[1]  = b/2 + 1           # Make sure exponents b/2
    e[n2] = 0                 # and 0 actually occur
    for i in 1:n2
        x[i] = (2*rand(rng, T)-1) * 2^(e[i])
        y[i] = (2*rand(rng, T)-1) * 2^(e[i])
    end


    # Second half of the vectors such that
    #   (*) log2( dot (x[1:i], y[1:i]) ) decreases from b/2 to 0
    δe = -b/(2*(n-n2-1))
    e = b/2:δe:0
    for i in eachindex(e)
        # Random x[i]
        cx = (2*rand(rng)-1) * 2^(e[i])
        x[i+n2] = cx

        # y[i] chosen according to (*)
        cy = (2*rand(rng)-1) * 2^(e[i])
        y[i+n2] = (cy - T(dot(R.(x), R.(y)))) / cx
    end


    # Random permutation of x and y
    perm = randperm(rng, n)
    X = x[perm]
    Y = y[perm]

    # Dot product, rounded to nearest
    d = T(dot(R.(X), R.(Y)))

    # Actual condition number
    c_ = 2 * dot(abs.(X), abs.(Y)) / abs(d)

    (X,Y,d,c_)
end


function generate_sum_(n, c::T, rng) where {T}
    R = Rational{BigInt}

    (x, y, _, _) = generate_dot_(n÷2, c, rng)

    z = (two_prod.(x, y)
         |> Iterators.flatten
         |> collect)

    # Complete if necessary
    if length(z) < n
        push!(z, rand(rng))
    end

    z = shuffle(z)

    # Sum, rounded to nearest
    s = T(sum(R.(z)))

    # Actual condition number
    c_ = sum(abs.(z)) / abs(s)

    (z, s, c_)
end

end
