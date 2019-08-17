println("Loading required packages...")
using Plots, JSON

function plot_results()
    println("Generating plots...")
    for filename in readdir()
        endswith(filename, ".json") || continue
        plot_results(replace(filename, ".json" => ""))
    end
end

function plot_results(filename)
    results = JSON.parsefile(filename*".json")
    if get(results, "type", nothing) == nothing
        @warn "Badly formatted file: `$filename.json'"
        return
    end

    println("-> $filename")
    plot_results(Val(Symbol(results["type"])), filename, results)
end

function plot_results(::Val{:accuracy}, filename, results)
    title = results["title"]
    labels = results["labels"]
    data = results["data"]

    scatter(title=title,
            xscale=:log10, yscale=:log10,
            xlabel="Condition number",
            ylabel="Relative error")

    markers = Symbol[:circle, :+, :rect, :x]

    for i in 1:length(labels)
        scatter!(Float64.(data[1]), Float64.(data[i+1]), label=labels[i], markershape=markers[i])
    end

    savefig(filename*".pdf")
    savefig(filename*".svg")
end

function plot_results(::Val{:ushift}, filename, results)
    title  = results["title"]
    labels = results["labels"]
    data   = results["data"]

    p = plot(title=title,
             xlabel="log2(U)",
             ylabel="Time [ns/elem]")

    for i in 1:length(labels)
        plot!(Float64.(data[1]), Float64.(data[i+1]), label="2^$(Int(round(log2(labels[i])))) elems")
    end

    savefig(filename*".pdf")
    savefig(filename*".svg")
end

function plot_results(::Val{:performance}, filename, results)
    title  = results["title"]
    labels = results["labels"]
    data   = results["data"]

    p = plot(title=title,
             xscale=:log10,
             xlabel="Vector size",
             ylabel="Time [ns/elem]")

    for i in 1:length(labels)
        plot!(Float64.(data[1]), Float64.(data[i+1]), label=labels[i])
    end

    savefig(filename*".pdf")
    savefig(filename*".svg")
end
