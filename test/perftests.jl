println("Loading required packages...")
using LinearAlgebra, Random, Printf, Statistics
using BenchmarkTools, JSON

using AccurateArithmetic
using AccurateArithmetic.Summation: accumulate, two_sum, fast_two_sum
using AccurateArithmetic.Summation: sumAcc, dotAcc, compSumAcc, compDotAcc
using AccurateArithmetic.Test

output(x) = @printf "%.2e " x
err(val::T, ref::T) where {T} = min(1, max(eps(T), abs((val-ref)/ref)))

FAST_TESTS = false



# * Accuracy

function run_accuracy(gen, funs, labels, title, filename)
    println("-> $title")

    n = 100     # Vector size
    c1 = 2.     # Condition number (min)
    c2 = 1e45   # -                (max)
    logstep = 2 # Step for condition number increase (log scale)

    data = [Float64[] for _ in 1:(1+length(funs))]

    c = c1
    while c < c2
        i = 1
        (x, d, C) = gen(rand(n:n+10), c)
        output(C)
        push!(data[i], C)

        for fun in funs
            i += 1
            r = fun(x...)
            ε = err(r, d)
            output(ε)
            push!(data[i], ε)
        end

        println()
        c *= logstep
    end

    open(filename*".json", "w") do f
        JSON.print(f, Dict(
            :type   => :accuracy,
            :title  => title,
            :labels => labels,
            :data   => data))
    end
end


function run_accuracy()
    println("Running accuracy tests...")

    function gen_sum(n, c)
        (x, d, c) = generate_sum(n, c)
        ((x,), d, c)
    end
    run_accuracy(gen_sum,
                 (sum,        sum_naive, sum_oro, sum_kbn),
                 ("pairwise", "naive",   "oro",   "kbn"),
                 "Error of summation algorithms",
                 "sum_accuracy")


    function gen_dot(n, c)
        (x, y, d, c) = generate_dot(n, c)
        ((x, y), d, c)
    end
    run_accuracy(gen_dot,
                 (dot,    dot_naive, dot_oro),
                 ("blas", "naive",   "oro"),
                 "Error of dot product algorithms",
                 "dot_accuracy")
end



# * Optimal u_shift

function run_ushift(gen, acc, title, filename)
    println("-> $title")

    if FAST_TESTS
        title *= " [FAST]"
        sizes = [2^(3*i) for i in 3:4]
        ushifts = (0,2)
        BenchmarkTools.DEFAULT_PARAMETERS.evals = 1
        BenchmarkTools.DEFAULT_PARAMETERS.seconds = 0.5
    else
        sizes = [2^(3*i) for i in 2:6]
        ushifts = 0:4
        BenchmarkTools.DEFAULT_PARAMETERS.evals = 2
        BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5.0
    end

    data = [[] for _ in 1:(1+length(sizes))]
    for ushift in ushifts
        i = 1
        print(ushift, " ")
        push!(data[i], ushift)

        for n in sizes
            i += 1
            x = gen(n)

            b = @benchmark accumulate($x, $acc, $(Val(:scalar)), $(Val(ushift)))
            t = minimum(b.times) / n
            output(t)
            push!(data[i], t)
        end
        println()
    end

    open(filename*".json", "w") do f
        JSON.print(f, Dict(
            :type   => :ushift,
            :title  => title,
            :labels => sizes,
            :data   => data))
    end
end


function run_ushift()
    BenchmarkTools.DEFAULT_PARAMETERS.evals = 2
    println("Finding optimal ushift...")

    run_ushift(n->(rand(n),), sumAcc,
               "Performance of naive summation",
               "sum_naive_ushift")

    run_ushift(n->(rand(n),), compSumAcc(two_sum),
               "Performance of ORO summation",
               "sum_oro_ushift")

    run_ushift(n->(rand(n),), compSumAcc(fast_two_sum),
               "Performance of KBN summation",
               "sum_kbn_ushift")

    run_ushift(n->(rand(n), rand(n)), dotAcc,
               "Performance of naive dot product",
               "dot_naive_ushift")

    run_ushift(n->(rand(n), rand(n)), compDotAcc,
               "Performance of compensated dot product",
               "dot_oro_ushift")
end



# * Performance comparisons

function run_performance(n2, gen, funs, labels, title, filename)
    println("-> $title")

    if FAST_TESTS
        title *= " [FAST]"
        logstep = 100.
        BenchmarkTools.DEFAULT_PARAMETERS.evals = 1
        BenchmarkTools.DEFAULT_PARAMETERS.seconds = 0.5
    else
        logstep = 1.1
        BenchmarkTools.DEFAULT_PARAMETERS.evals = 2
        BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5.0
    end

    data = [Float64[] for _ in 1:(1+length(funs))]
    n = 32
    while n < n2
        i = 1
        x = gen(n)
        output(n)
        push!(data[i], n)

        for fun in funs
            i += 1
            b = @benchmark $fun($(x)...)
            t = minimum(b.times) / n
            output(t)
            push!(data[i], t)
        end

        println()
        N = Int(round(n*logstep))
        N = 32*div(N, 32)
        n = max(N, n+32)
    end

    open(filename*".json", "w") do f
        JSON.print(f, Dict(
            :type      => :performance,
            :title     => title,
            :labels    => labels,
            :elem_size => sizeof(gen(1)),
            :data      => data))
    end
end


function run_performance()
    println("Running performance tests...")

    run_performance(1e8, n->(rand(n),),
                    (sum,        sum_naive, sum_oro, sum_kbn),
                    ("pairwise", "naive",   "oro",   "kbn"),
                    "Performance of summation implementations",
                    "sum_performance")

    BLAS.set_num_threads(1)
    run_performance(3e7, n->(rand(n), rand(n)),
                    (dot,    dot_naive, dot_oro),
                    ("blas", "naive",   "oro"),
                    "Performance of dot product implementations",
                    "dot_performance")
end



# * All tests

function run_tests(fast=false)
    global FAST_TESTS = fast
    print("Running tests")
    FAST_TESTS && print(" in FAST mode")
    println("...\n")

    run_accuracy()
    sleep(5)
    run_ushift()
    sleep(5)
    run_performance()
    println("Normal end of the performance tests")
end
