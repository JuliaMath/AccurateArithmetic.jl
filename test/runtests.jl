using AccurateArithmetic
using Test

using AccurateArithmetic.Summation: accumulate
using AccurateArithmetic.Summation: sumAcc, compSumAcc, mixedSumAcc
using AccurateArithmetic.Summation: dotAcc, compDotAcc, mixedDotAcc
using AccurateArithmetic.Test: generate_sum, generate_dot
using LinearAlgebra
using StableRNGs


@testset "AccurateArithmetic" begin
    rng = StableRNG(42)

    @testset "Tests" begin
        @testset "generate_sum" begin
            @testset "vector length" begin
                @testset "F64" begin
                    for n in 100:110
                        let (x, s, c_) = generate_sum(n, 1e10; rng=rng)
                            @test eltype(x) === Float64
                            @test s isa Float64
                            @test length(x) == n
                        end
                    end
                end
                @testset "F32" begin
                    for n in 100:110
                        let (x, s, c_) = generate_sum(n, 1f5; rng=rng)
                            @test eltype(x) === Float32
                            @test s isa Float32
                            @test length(x) == n
                        end
                    end
                end
            end

            @testset "condition number" begin
                @testset "F64" begin
                    for c in (1e10, 1e20)
                        let (x, s, c_) = generate_sum(101, c; rng=rng)
                            @test eltype(x) === Float64
                            @test s isa Float64
                            @test c/3 < c_ < 3c
                        end
                    end
                end
                @testset "F32" begin
                    for c in (1f5, 1f10)
                        let (x, s, c_) = generate_sum(101, c; rng=rng)
                            @test eltype(x) === Float32
                            @test s isa Float32
                            @test c/3 < c_ < 3c
                        end
                    end
                end
            end
        end

        @testset "generate_dot" begin
            @testset "vector length" begin
                @testset "F64" begin
                    for n in 100:110
                        let (x, y, s, c_) = generate_dot(n, 1e10; rng=rng)
                            @test eltype(x) === Float64
                            @test s isa Float64
                            @test length(x) == n
                            @test length(y) == n
                        end
                    end
                end
                @testset "F32" begin
                    for n in 100:110
                        let (x, y, s, c_) = generate_dot(n, 1f5; rng=rng)
                            @test eltype(x) === Float32
                            @test s isa Float32
                            @test length(x) == n
                            @test length(y) == n
                        end
                    end
                end
            end

            @testset "condition number" begin
                @testset "F64" begin
                    for c in (1e10, 1e20)
                        let (x, y, s, c_) = generate_dot(101, c; rng=rng)
                            @test s isa Float64
                            @test c/3 < c_ < 3c
                        end
                    end
                end
                @testset "F32" begin
                    for c in (1f5, 1f10)
                        let (x, y, s, c_) = generate_dot(101, c; rng=rng)
                            @test s isa Float32
                            @test c/3 < c_ < 3c
                        end
                    end
                end
            end
        end
    end

    @testset "summation" begin
        @testset "naive" begin
            @testset "F64" begin
                for N in 100:110
                    x = rand(rng, N)
                    ref = sum(x)
                    @test ref isa Float64
                    @test ref ≈ sum_naive(x)

                    acc = sumAcc
                    @test ref ≈ accumulate((x,), acc, Val(:scalar), Val(2))
                    @test ref ≈ accumulate((x,), acc, Val(:mask),   Val(2))
                end
            end
            @testset "F32" begin
                for N in 100:110
                    x = rand(rng, Float32, N)
                    ref = sum(x)
                    @test ref isa Float32
                    @test ref ≈ sum_naive(x)

                    acc = sumAcc
                    @test ref ≈ accumulate((x,), acc, Val(:scalar), Val(2))
                    @test ref ≈ accumulate((x,), acc, Val(:mask),   Val(2))
                end
            end
        end

        @testset "compensated" begin
            @testset "F64" begin
                for N in 100:110
                    x, ref, _ = generate_sum(N, 1e10; rng=rng)
                    @test ref isa Float64
                    @test ref == sum_oro(x)
                    @test ref == sum_kbn(x)

                    acc = compSumAcc(two_sum)
                    @test ref == accumulate((x,), acc, Val(:scalar), Val(2))
                    @test ref == accumulate((x,), acc, Val(:mask),   Val(2))
                end
            end
            @testset "F32" begin
                for N in 100:110
                    x, ref, _ = generate_sum(N, 1f5; rng=rng)
                    @test ref isa Float32
                    @test ref == sum_oro(x)
                    @test ref == sum_kbn(x)

                    acc = compSumAcc(two_sum)
                    @test ref == accumulate((x,), acc, Val(:scalar), Val(2))
                    @test ref == accumulate((x,), acc, Val(:mask),   Val(2))
                end
            end
        end

        @testset "mixed" begin
            for N in 100:110
                # Only test for approximate equality here, since sum_mixed
                # returns a Float64 whereas the reference value is a Float32

                x, ref, _ = generate_sum(N, 1f7; rng=rng)
                @test ref isa Float32
                @test ref ≈ sum_mixed(x)

                acc = mixedSumAcc
                @test ref ≈ accumulate((x,), acc, Val(:scalar), Val(2))
                @test ref ≈ accumulate((x,), acc, Val(:mask),   Val(2))
            end
        end
    end

    @testset "dot product" begin
        @testset "naive" begin
            @testset "F64" begin
                for N in 100:110
                    x = rand(rng, N)
                    y = rand(rng, N)
                    ref = dot(x, y)
                    @test ref isa Float64
                    @test ref ≈ dot_naive(x, y)

                    acc = dotAcc
                    @test ref ≈ accumulate((x,y), acc, Val(:scalar), Val(2))
                    @test ref ≈ accumulate((x,y), acc, Val(:mask),   Val(2))
                end
            end
            @testset "F32" begin
                for N in 100:110
                    x = rand(rng, Float32, N)
                    y = rand(rng, Float32, N)
                    ref = dot(x, y)
                    @test ref isa Float32
                    @test ref ≈ dot_naive(x, y)

                    acc = dotAcc
                    @test ref ≈ accumulate((x,y), acc, Val(:scalar), Val(2))
                    @test ref ≈ accumulate((x,y), acc, Val(:mask),   Val(2))
                end
            end
        end

        @testset "compensated" begin
            @testset "F64" begin
                for N in 100:110
                    x, y, ref, _ = generate_dot(N, 1e10; rng=rng)
                    @test ref isa Float64
                    @test ref == dot_oro(x, y)

                    acc = compDotAcc
                    @test ref == accumulate((x,y), acc, Val(:scalar), Val(2))
                    @test ref == accumulate((x,y), acc, Val(:mask),   Val(2))
                end
            end
            @testset "F32" begin
                for N in 100:110
                    x, y, ref, _ = generate_dot(N, 1f5; rng=rng)
                    @test ref isa Float32
                    @test ref == dot_oro(x, y)

                    acc = compDotAcc
                    @test ref == accumulate((x,y), acc, Val(:scalar), Val(2))
                    @test ref == accumulate((x,y), acc, Val(:mask),   Val(2))
                end
            end
        end

        @testset "mixed" begin
            for N in 100:110
                # Only test for approximate equality here, since dot_mixed
                # returns a Float64 whereas the reference value is a Float32

                x, y, ref, _ = generate_dot(N, 1f7; rng=rng)
                @test ref isa Float32
                @test ref ≈ dot_mixed(x, y)

                acc = mixedDotAcc
                @test ref ≈ accumulate((x,y), acc, Val(:scalar), Val(2))
                @test ref ≈ accumulate((x,y), acc, Val(:mask),   Val(2))
            end
        end
    end
end

using BenchmarkTools
BLAS.set_num_threads(1)
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1000

println("\nsize 32")
x = rand(32)
y = rand(32)
print("  sum_kbn  "); @btime sum_kbn($x)
print("  sum_oro  "); @btime sum_oro($x)
print("  sum_naive"); @btime sum_naive($x)
print("  sum      "); @btime sum($x)
println()
print("  dot_oro  "); @btime dot_oro($x, $y)
print("  dot_naive"); @btime dot_naive($x, $y)
print("  dot      "); @btime dot($x, $y)

println("\nsize 10_000")
x = rand(10_000)
y = rand(10_000)
print("  sum_kbn  "); @btime sum_kbn($x)
print("  sum_oro  "); @btime sum_oro($x)
print("  sum_naive"); @btime sum_naive($x)
print("  sum      "); @btime sum($x)
println()
print("  dot_oro  "); @btime dot_oro($x, $y)
print("  dot_naive"); @btime dot_naive($x, $y)
print("  dot      "); @btime dot($x, $y)

BenchmarkTools.DEFAULT_PARAMETERS.evals = 10
println("\nsize 1_000_000")
x = rand(1_000_000)
y = rand(1_000_000)
print("  sum_kbn  "); @btime sum_kbn($x)
print("  sum_oro  "); @btime sum_oro($x)
print("  sum_naive"); @btime sum_naive($x)
print("  sum      "); @btime sum($x)
println()
print("  dot_oro  "); @btime dot_oro($x, $y)
print("  dot_naive"); @btime dot_naive($x, $y)
print("  dot      "); @btime dot($x, $y)

println("\nsize 100_000_000")
x = rand(100_000_000)
y = rand(100_000_000)
print("  sum_kbn  "); @btime sum_kbn($x)
print("  sum_oro  "); @btime sum_oro($x)
print("  sum_naive"); @btime sum_naive($x)
print("  sum      "); @btime sum($x)
println()
print("  dot_oro  "); @btime dot_oro($x, $y)
print("  dot_naive"); @btime dot_naive($x, $y)
print("  dot      "); @btime dot($x, $y)
