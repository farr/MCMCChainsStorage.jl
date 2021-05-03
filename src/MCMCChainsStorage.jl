module MCMCChainsStorage

import Base: read, write

using HDF5
using MCMCChains

"""
    write(f::Union{HDF5.File, HDF5.Group}, chains::Chains)

Write MCMCChains object to the HDF5 file or group.
"""
function Base.write(f::Union{HDF5.File, HDF5.Group}, c::Chains)
    for s in sections(c)
        g = create_group(f, string(s))
        for n in names(c, s)
            g[string(n), shuffle=(), compress=3] = Array(c[n])
        end
    end
end

"""
    read(f::Union{HDF5.File, HDF5.Group}, ::Type{Chains})

Read a chain object from the given HDF5 file our group.

"""
function Base.read(f::Union{HDF5.File, HDF5.Group}, ::Type{Chains})
    secs = keys(f)
    pns = []
    datas = []
    name_map = Dict()
    for s in secs
        ns = keys(f[s])
        name_map[Symbol(s)] = ns
        for n in ns
            push!(pns, n)
            push!(datas, read(f[s], n))
        end
    end

    nc, ns = size(datas[1])
    np = size(datas,1)

    a = zeros(nc, np, ns)

    for i in 1:np
        a[:,i,:] = datas[i]
    end

    Chains(a, pns, name_map)
end


end # module
