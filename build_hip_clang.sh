#!/bin/bash

basedir=${PWD}

function die()
{
	echo $0: $1
	exit 1
}

function build_components()
{
	# verify that ROCm is installed
	echo $0: verifying ROCm installation...
	rocm_version=`cat /opt/rocm/.info/version 2> /dev/null`
	if [ $? -eq 0 ]; then
		echo $0: ROCm ${rocm_version} is installed.
	else
		die "No ROCm installation found, aborting."
	fi

	echo $0: building AMD-clang/HIP-clang per the instructions on:
	echo $0: "  https://github.com/ROCm-Developer-Tools/HIP/blob/master/INSTALL.md#amd-clang"

	echo $0: cloning LLVM
	git clone -b amd-common https://github.com/RadeonOpenCompute/llvm.git \
		|| die "Error cloning LLVM"

	echo $0: cloning clang
	git clone -b amd-common https://github.com/RadeonOpenCompute/clang llvm/tools/clang \
		|| die "Error cloning clang"

	echo $0: cloning lld
	git clone -b amd-common https://github.com/RadeonOpenCompute/lld llvm/tools/lld \
		|| die "Error cloning lld"

	echo $0: building LLVM, clang, and lld
	mkdir -p build/llvm
	cd build/llvm
	cmake \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm \
	    -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" \
		${basedir}/llvm \
		|| die "Error in cmake for LLVM, clang, or lld"
	make -j `nproc` || die "Error in building LLBM, clang, or lld"
	cd ${basedir}

	echo $0: cloning ROCm device library
	git clone -b master https://github.com/RadeonOpenCompute/ROCm-Device-Libs.git \
		|| die "Error cloning ROCm device library"

	echo $0: building ROCm device library
	mkdir -p build/device_libs
	cd build/device_libs
	CC=${basedir}/build/llvm/bin/clang cmake \
		-DLLVM_DIR=${basedir}/build/llvm \
		-DCMAKE_INSTALL_PREFIX=/opt/rocm \
		${basedir}/ROCm-Device-Libs \
		|| die "Error in cmake for ROCm device libs"
	make -j `nproc` || die "Error in building ROCm device libs"
	cd ${basedir}

	echo $0: cloning HIP
	git clone -b master https://github.com/ROCm-Developer-Tools/HIP.git \
		|| die "Error in cloning HIP"

	echo $0: building HIP
	mkdir -p build/hip
	cd build/hip
	cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCOMPILE_HIP_ATP_MARKER=1 \
		-DHIP_COMPILER=clang \
		-DCMAKE_INSTALL_PREFIX=/opt/rocm/hip-clang \
		${basedir}/HIP \
		|| die "Error in cmake for HIP"
	make -j `nproc` || die Error building HIP
	cd ${basedir}

	exit
}

function install_components()
{
	echo Installing LLVM, clang and lld
	cd ${basedir}/build/llvm
	sudo make install || die "Error installing LLVM, clang and lld"

	echo Installing ROCm device libs
	cd ${basedir}/build/device_libs
	sudo make install || die "Error installing ROCm device libs"

	echo Installing HIP
	cd ${basedir}/build/hip
	sudo make install || die "Error installing HIP"

	exit
}

function usage()
{
	echo "usage: $0 <option>"
	echo "options:"
	echo "-h     Show this help message."
	echo "-b     Build all components."
	echo "-i     Install all components. Requires sudo privileges, and"
	echo "       assumes all components have been built."
	exit
}

if [ $# -ne 1 ]; then
	usage
fi
if getopts "hbit" opt; then
	case "$opt" in
		h)
			usage
			exit 0
			;;
		b)
			build_components
			exit 0
			;;
		i)
			install_components
			exit 0
			;;
	esac	
fi

usage







### Notes
## HIP dependencies: see https://github.com/ROCm-Developer-Tools/HIP/blob/master/install.sh
# sudo apt install dpkg-dev rpm doxygen libelf-dev rename
## ROCm dependencies: todo
#
## Commits:
# llvm: a152ce59
# clang: ddeb7926
# lld: 60990336
# ROCm device library: 95e8c8da
# HIP: 57397862
