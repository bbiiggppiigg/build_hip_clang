# Building HIP-clang from public repositories

`build_hip_clang.sh` clones a bunch of ROCm repositories needed for
hip-clang into the current directory, and builds/installs them, such
that HIP code can either be built with hip-clang, or with hcc: both
compilers can coexist happily together on the same system. 

## Prerequisites

One of the components to be built, HIP, has a number of dependencies. See
[the HIP build script]
(https://github.com/ROCm-Developer-Tools/HIP/blob/master/install.sh), 
or simply do
```
sudo apt install dpkg-dev rpm doxygen libelf-dev rename
```

## Build script usage

```
usage: ./build_hip_clang.sh <option>
options:
-h     Show this help message.
-b     Build all components.
-i     Install all components. Requires sudo privileges, and
       assumes all components have been built.
```

## Using hip-clang

The script installs hip-clang under `/opt/rocm/hip-clang`. It is most easily
used via `/opt/rocm/hip-clang/bin/hipcc`. To compile HIP code with hip-clang,
it needs to be passed the `-x hip` argument. If hipcc doesn't do this
automagically, you need to pass the argument to hipcc. To see what hipcc
passes to hip-clang, invoke hipcc with `HIPCC_VERBOSE=1`.

If you want to play with rocm-gdb, hip-clang is the right tool: rocm-gdb works
way better on code compiled with hip-clang than on code compiled with hcc. 
However, you need to compile with `-mcode-object-v3` for rocm-gdb to make
sense of the ELF format.

Any AMD GPU libraries used by code compiled with hip-clang need to be compiled
with hip-clang too. Or else.

## Latest recorded successful build

Git commit hashes of the various components in the latest successful build:
* llvm: 6a76b6e3451caf28415ba879aa9f2bd77ead843d
* clang: e6a3c23fe3d9adff51a07e454941fa0cf641a19a
* lld: e898dad309c45cfc64b93459f39a6e442ec20633
* ROCm device library: ac6a51547af45d31d116502e835ad6c762d139d5
* HIP: e919a8246e588ca75e6fc83b1e6bbf866eb94cdf

## Bonus script: hc_extractkernel

Binaries created with hip-clang have a different format than binaries created
with hipcc, and consequently, `/opt/rocm/bin/extractkernel` does not work
with hip-clang binaries. Included in this repo is `hc_extractkernel`, a
modified version of `extractkernel` for hip-clang. Due to the different
format of hip-clang generated executables, kernels are dumped into multiple
files, with one kernel per `*.isa` file.

Note: based on limited experimentation, I made the assumption that offload
bundles in the binary are 16-byte aligned. That may be incorrect; the alignment
could also be 8-byte or 32-byte, for instance. If `hc_extractkernel` fails to
extract some kernels, it may be useful to experiment with the alignment; see
the tail of the script. Please let me know if you find a different alignment
than 16 bytes.
