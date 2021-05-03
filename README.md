# MCMCChainsStorage.jl: Storing Your Chains on Disk

The `MCMCChainsStorage.jl` package provides options for storing your
`MCMCChains.jl` chains on disk without using serialization.  Serialization is
not suitable for long-term storage; or for sharing your chains to colleagues
with different operating systems, Julia versions, or even without Julia.
`MCMCChainsStorage.jl` solves these problems.

Currently only storage in HDF5 file formats is supported, but other storage
options may be added in the future.

## Installation

TODO: put this package in the general Julia package registry.

To install the package into a Julia environment, start Julia, activate the
environment, enter the package management context (type `]`), and issue the
command

```julia
pkg> add https://github.com/farr/MCMCChainsStorage.jl.git
```

### Dependencies

The `MCMCChainsStorage` package depends on the `MCMCChains` and the `HDF5`
packages.  If you do not have these packages installed on your system,
installing `MCMCChainsStorage` will install them automatically.

## Usage

The packages provides methods for `Base.read` and `Base.write` that read an
MCMCChains object from or write it to HDF5 storage:

```julia
using HDF5
using MCMCChains
using MCMCChainsStorage

# Construct a chain and write it out...
chain = Chains(randn(500, 2, 4), [:a, :b])
h5open("an_hdf5_file.h5", "w") do f
  write(f, chain)
end

# ...and we can get it back
chain = h5open("an_hdf5_file.h5", "r") do f
  read(f, Chains)
end
```

Reading and writing preserves the sections of the chain, so if you have metadata
stored in, for example, the "internals" section, it will be written out and read
back properly.

It is also possible to write a chain to a group in a larger HDF5 file:

```julia
h5open("another_hdf5_file.h5", "w") do f
  g = create_group(f, "a_chain")
  write(g, chain)
end

chain = h5open("another_hdf5_file.h5", "r") do f
  read(f["a_chain"], Chains)
end
```

## Details and Storage Format

The chain is stored with one group for each section (`parameters`, `internals`,
etc).  Each "name" within the section is stored as a separate HDF5 data set, so
arrays in the chain will be placed in data sets named "x[1]", "x[2]", etc.
Compression is enabled by default; currently there is no way to change this
default, but why would you want to?  An advantage of this format is that generic
tools like `h5ls` will produce a reasonable description of the chain; and it is
straightforward to reconstruct the chain without too much code in *any* language
that can interface with the HDF5 storage format.
