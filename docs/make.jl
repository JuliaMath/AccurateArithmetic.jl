using AccurateArithmetic, Documenter

makedocs(
    modules = [AccurateArithmetic],
    clean = false,
    format = :html,
    sitename = "AccurateArithmetic.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Tim Holy, and other contributors",
    pages = [
        "Home" => "index.md",
        "Refs" => "references.md"
    ],
)

deploydocs(
    julia = "nightly",
    repo = "github.com/JuliaMath/AccurateArithmetic.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
