using LinearAlgebra, Random, Printf, Statistics
using Plots, BenchmarkTools

using AccurateArithmetic
using AccurateArithmetic: cascaded_eft, two_sum
using AccurateArithmetic.Test

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

        r = sum_kbn(x)
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
             ylabel="Time [ns/elem]")

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
             ylabel="Time [ns/elem]")
    plot!(data[1], data[2], label="mask")
    plot!(data[1], data[3], label="scalar")
    display(p)
end

function run_tests()
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

run_tests()
