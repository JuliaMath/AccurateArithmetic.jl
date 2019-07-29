using AccurateArithmetic
using Test

using AccurateArithmetic: cascaded_eft, two_sum
using AccurateArithmetic.Test: generate_sum


@testset "summation" begin
    x, ref, _ = generate_sum(100, 1e10)
    @test sum_oro(x) == ref
    @test sum_kbn(x) == ref

    @test ref == cascaded_eft(x, two_sum, Val(:scalar), Val(2))
    @test ref == cascaded_eft(x, two_sum, Val(:mask),   Val(2))
end


using BenchmarkTools

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1000
@btime cascaded_eft($(rand(10_000)),    two_sum, Val(:scalar), Val(2))

BenchmarkTools.DEFAULT_PARAMETERS.evals = 10
@btime cascaded_eft($(rand(1_000_000)), two_sum, Val(:scalar), Val(2))

x = rand(100_000_000)
@btime sum_oro($x)
@btime sum($x)
