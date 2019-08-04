using LinearAlgebra, Random, Printf, Statistics
using Plots, BenchmarkTools, JSON

using AccurateArithmetic
using AccurateArithmetic: accumulate, sumAcc, dotAcc, compSumAcc, compDotAcc, two_sum
using AccurateArithmetic.Test

output(x) = @printf "%.2e " x
err(val, ref) = min(1, max(eps(Float64), abs((val-ref)/ref)))

function accuracy_run(n, c1, c2, logstep, gen, funs, outfile)
    data = [Float64[] for _ in 1:(1+length(funs))]

    c = c1
    while c < c2
        i = 1
        (x, d, C) = gen(n, c)
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

    open(outfile, "w") do f
        JSON.print(f, data)
    end
end

function accuracy_plt(title, labels, outfile, pltfile)
    data = JSON.parsefile(outfile)

    scatter(title=title,
            xscale=:log10, yscale=:log10,
            xlabel="Condition number",
            ylabel="Relative error")

    for i in 1:length(labels)
        scatter!(data[1], data[i+1], label=labels[i])
    end

    savefig(pltfile)
end

function performance_run(n1, n2, logstep, gen, funs, outfile)
    data = [Float64[] for _ in 1:(1+length(funs))]

    n = n1
    while n < n2
        sleep(1)

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

        open(outfile, "w") do f
            JSON.print(f, data)
        end
    end
end

function performance_plt(title, labels, outfile, pltfile)
    data = JSON.parsefile(outfile)

    p = plot(title=title,
             xscale=:log10,
             xlabel="Vector size",
             ylabel="Time [ns/elem]")

    for i in 1:length(labels)
        plot!(data[1], data[i+1], label=labels[i])
    end

    savefig(pltfile)
end

function ushift_run(gen, acc, outfile)
    sizes = [10^i for i in 2:6]
    data = [[] for _ in 1:(1+length(sizes))]
    for ushift in 0:4
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

    open(outfile, "w") do f
        JSON.print(f, Dict(
            "labels"=>sizes,
            "data"=>data))
    end
end

function ushift_plt(title, outfile, pltfile)
    json = JSON.parsefile(outfile)
    data   = json["data"]
    labels = json["labels"]

    p = plot(title=title,
             xlabel="u_shift",
             ylabel="Time [ns/elem]")

    for i in 1:length(labels)
        plot!(data[1], data[i+1], label="10^$(Int(round(log10(labels[i])))) elems")
    end

    savefig(pltfile)
end

function run_tests()
    BenchmarkTools.DEFAULT_PARAMETERS.evals = 2

    println("Running accuracy tests...")

    begin
        outfile = "sum_accuracy.json"
        pltfile = "sum_accuracy.pdf"
        function gen_sum(n, c)
            (x, d, c) = generate_sum(n, c)
            ((x,), d, c)
        end
        accuracy_run(100, 2., 1e45, 2.,
                     gen_sum,
                     (sum, sum_naive, sum_oro, sum_kbn),
                     outfile)
        accuracy_plt("Error of summation algorithms",
                     ("pairwise", "naive", "oro", "kbn"),
                     outfile, pltfile)


        outfile = "dot_accuracy.json"
        pltfile = "dot_accuracy.pdf"
        function gen_dot(n, c)
            (x, y, d, c) = generate_dot(n, c)
            ((x, y), d, c)
        end
        accuracy_run(100, 2., 1e45, 2.,
                     gen_dot,
                     (dot, dot_naive, dot_oro),
                     outfile)
        accuracy_plt("Error of dot product algorithms",
                     ("blas", "naive", "oro"),
                     outfile, pltfile)
    end


    sleep(5)
    println("Finding optimal ushift...")
    begin
        outfile = "sum_naive_ushift.json"
        pltfile = "sum_naive_ushift.pdf"
        ushift_run(n->(rand(n),),
                   sumAcc,
                   outfile)
        ushift_plt("Performance of naive summation",
                   outfile, pltfile)


        outfile = "sum_oro_ushift.json"
        pltfile = "sum_oro_ushift.pdf"
        ushift_run(n->(rand(n),),
                   compSumAcc(two_sum),
                   outfile)
        ushift_plt("Performance of compensated summation",
                   outfile, pltfile)


        outfile = "dot_naive_ushift.json"
        pltfile = "dot_naive_ushift.pdf"
        ushift_run(n->(rand(n), rand(n)),
                   dotAcc,
                   outfile)
        ushift_plt("Performance of naive dot product",
                   outfile, pltfile)


        outfile = "dot_oro_ushift.json"
        pltfile = "dot_oro_ushift.pdf"
        ushift_run(n->(rand(n), rand(n)),
                   compDotAcc,
                   outfile)
        ushift_plt("Performance of compensated dot product",
                   outfile, pltfile)
    end


    sleep(5)
    println("Running performance tests...")
    begin
        outfile = "sum_performance.json"
        pltfile = "sum_performance.pdf"
        performance_run(32, 1e8, 1.1,
                        n->(rand(n),),
                        (sum, sum_naive, sum_oro, sum_kbn),
                        outfile)
        performance_plt("Performance of summation implementations",
                        ("pairwise", "naive", "oro", "kbn"),
                        outfile, pltfile)


        BLAS.set_num_threads(1)
        outfile = "dot_performance.json"
        pltfile = "dot_performance.pdf"
        performance_run(32, 3e7, 1.1,
                        n->(rand(n), rand(n)),
                        (dot, dot_naive, dot_oro),
                        outfile)
        performance_plt("Performance of dot product implementations",
                        ("blas", "naive", "oro"),
                        outfile, pltfile)
    end
end

run_tests()
