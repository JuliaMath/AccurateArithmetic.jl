using AccurateArithmetic
using Test

using AccurateArithmetic: accumulate, compSumAcc, two_sum
using AccurateArithmetic.Test: generate_sum

@testset "AccurateArithmetic" begin
    @testset "Tests" begin
        @testset "generate_sum" begin

            @testset "vector length" begin
                for n in 100:110
                    let (x, s, c_) = generate_sum(n, 1e10)
                        @test length(x) == n
                    end
                end
            end

            @testset "condition number" begin
                for c in (1e10, 1e20)
                    let (x, s, c_) = generate_sum(101, c)
                        @test c/100 < c_ < 1000c
                    end
                end
            end
        end
    end

    @testset "summation" begin
        @testset "naive" begin
            for N in 100:110
                x = rand(N)
                ref = sum(x)
                @test ref ≈ sum_naive(x)

                acc = AccurateArithmetic.sumAcc
                @test ref ≈ accumulate((x,), acc, Val(:scalar), Val(2))
                @test ref ≈ accumulate((x,), acc, Val(:mask),   Val(2))
            end
        end

        @testset "compensated" begin
            for N in 100:110
                x, ref, _ = generate_sum(N, 1e10)
                @test sum_oro(x) == ref
                @test sum_kbn(x) == ref

                acc = compSumAcc(two_sum)
                @test ref == accumulate((x,), acc, Val(:scalar), Val(2))
                @test ref == accumulate((x,), acc, Val(:mask),   Val(2))
            end
        end
    end
end

using BenchmarkTools

acc = compSumAcc(two_sum)

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1000
@btime accumulate($((rand(10_001),)),    $acc, Val(:scalar), Val(2))

BenchmarkTools.DEFAULT_PARAMETERS.evals = 10
@btime accumulate($((rand(1_000_001),)), $acc, Val(:scalar), Val(2))

x = rand(100_000_000)
@btime sum_oro($x)
@btime sum_naive($x)
@btime sum($x)
