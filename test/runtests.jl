using HDF5
using MCMCChains
using MCMCChainsStorage
using Test

@testset "Reading and writing a chain" begin
    # Test writing a chain out and reading it back in, with sections
    chain = Chains(randn(500, 4, 2), [:a, :b, :c, :d])
    chain = set_section(chain, Dict(:internals => [:c, :d], :parameters => [:a, :b]))

    mktemp() do path, io
        h5open(path, "w") do f
            write(f, chain)
        end

        chain2 = h5open(path, "r") do f
            read(f, Chains)
        end

        for par in [:a, :b, :c, :d]
            @test chain[par] == chain2[par]
        end
    end
end

@testset "Append generated quantities" begin
    @testset "Scalar quantities" begin 
        chain = Chains(randn(500, 4, 2), [:a, :b, :c, :d])
        genq = [(e = randn(), f = randn()) for i in 1:500, j in 1:2]
        full_chain = append_generated_quantities(chain, genq)
        @test full_chain[:e] == [x.e for x in genq]
    end
    @testset "Vector quantities" begin
        chain = Chains(randn(500, 4, 2), [:a, :b, :c, :d])
        genq = [(e = randn(3), f = randn(3)) for i in 1:500, j in 1:2]
        full_chain = append_generated_quantities(chain, genq)
        @test full_chain["e[2]"] == [x.e[2] for x in genq]
    end
end
