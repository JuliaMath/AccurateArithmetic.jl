using CompensatedAlgorithms
using Test, LinearAlgebra, Random, Printf, Statistics
using Plots, BenchmarkTools

using CompensatedAlgorithms: cascaded_eft, two_sum


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

function two_prod(x, y)
    p = x*y
    e = fma(x, y, -p)
    p, e
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


output(x) = @printf "%.2e " x
err(val, ref) = min(1, max(eps(Float64), abs((val-ref)/ref)))

function qual(n, c1, c2, logstep)
    data = [Float64[] for _ in 1:10]

    c = c1
    while c < c2
        (x, d, C) = generate_sum(n, c)
        output(C)
        push!(data[1], C)

        r = sum(x)
        ε = err(r, d)
        output(ε)
        push!(data[2], ε)

        r = sum_oro(x)
        ε = err(r, d)
        output(ε)
        push!(data[3], ε)

        r = sum_kahan(x)
        ε = err(r, d)
        output(ε)
        push!(data[4], ε)

        println()
        c *= logstep
    end

    data
end

function plot_qual(data)
    scatter(title="Error of summation algorithms",
            xscale=:log10, yscale=:log10,
            xlabel="Condition number",
            ylabel="Relative error")

    scatter!(data[1], data[2], label="sum")
    scatter!(data[1], data[3], label="oro")
    scatter!(data[1], data[4], label="kbn")
end

function perf(n1, n2, logstep)
    data = [Float64[] for _ in 1:10]

    n = n1
    while n < n2
        x = rand(n)
        output(n)
        push!(data[1], n)

        b = @benchmark sum($x)
        t = minimum(b.times) / n
        output(t)
        push!(data[2], t)

        b = @benchmark cascaded_eft($x, two_sum, Val(:scalar), Val(1))
        t = minimum(b.times) / n
        output(t)
        push!(data[3], t)

        b = @benchmark cascaded_eft($x, two_sum, Val(:scalar), Val(2))
        t = minimum(b.times) / n
        output(t)
        push!(data[4], t)

        println()
        N = Int(round(n*logstep))
        N = 32*div(N, 32)
        n = max(N, n+32)

        # plot_perf(data)
    end

    data
end

function plot_perf(data)
    p = plot(title="Performance of summation algorithms",
             xscale=:log10,
             xlabel="Vector size",
             ylabel="Time [µs/elem]")

    plot!(data[1], data[2], label="sum")
    plot!(data[1], data[3], label="oro, ushift=1")
    plot!(data[1], data[4], label="oro, ushift=2")

    display(p)
end


function mask_vs_scalar(N)
    data = [Float64[] for _ in 1:10]
    for n in N:N+8
        x = rand(n)
        output(n)
        push!(data[1], n)

        b = @benchmark cascaded_eft($x, two_sum, Val(:mask), Val(2))
        t = minimum(b.times) / n
        output(t)
        push!(data[2], t)

        b = @benchmark cascaded_eft($x, two_sum, Val(:scalar), Val(2))
        t = minimum(b.times) / n
        output(t)
        push!(data[3], t)

        println()
    end

    data
end


function plot_mvs(data)
    p = plot(title="Mask vs Scalar",
             xlabel="Vector size",
             ylabel="Time [µs/elem]")
    plot!(data[1], data[2], label="mask")
    plot!(data[1], data[3], label="scalar")
    display(p)
end

begin
    BenchmarkTools.DEFAULT_PARAMETERS.evals = 2

    println("Running quality tests...")
    data_qual = qual(100, 2., 1e45, 2.)
    plot_qual(data_qual)
    savefig("qual.svg")

    sleep(5)

    println("Running performance tests...")
    data_perf = perf(32, 1e8, 1.1)
    plot_perf(data_perf)
    savefig("perf.svg")

    sleep(5)

    println("Comparing variants: 'mask' vs 'scalar'...")
    data_mvs = mask_vs_scalar(32)
    plot_mvs(data_mvs)
    savefig("mvs.svg")
end
