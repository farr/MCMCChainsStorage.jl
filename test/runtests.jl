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
