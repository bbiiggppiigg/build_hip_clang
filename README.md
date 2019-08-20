# Building HIP-clang from public repositories

`build_hip_clang.sh` clones a bunch of ROCm repositories needed for
hip-clang into the current directory, and builds/installs them.

## Prerequisites

One of the components to be built, HIP, has a number of dependencies. See
[https://github.com/ROCm-Developer-Tools/HIP/blob/master/install.sh]
(the HIP build script), or simply do
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

## Latest recorded successful build

Git commit hashes of the various components in the latest successful build:
* llvm: 6a76b6e3451caf28415ba879aa9f2bd77ead843d
* clang: e6a3c23fe3d9adff51a07e454941fa0cf641a19a
* lld: e898dad309c45cfc64b93459f39a6e442ec20633
* ROCm device library: ac6a51547af45d31d116502e835ad6c762d139d5
* HIP: e919a8246e588ca75e6fc83b1e6bbf866eb94cdf
