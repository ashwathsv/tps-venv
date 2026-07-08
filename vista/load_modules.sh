#!/bin/bash
#set -euo pipefail

module purge

ml TACC \
   cmake/3.31.5 \
   ucc/1.7.0 \
   ucx/1.20.0 \
   xalt/3.1 \
   nvidia_math/12.4 \
   gcc/14.2.0 \
   cuda/12.5 \
   python3/3.11.8 \
   openmpi/5.0.7 \
   phdf5/1.14.6 \
   boost/1.86.0

# Compiler wrappers for all MPI-enabled builds
#export CC=mpicc
#export CXX=mpicxx
#export FC=mpifort
#export F77=mpifort

# Ensure MPI-launched ranks find the GCC 14 C++ runtime
export GCC_LIBDIR
GCC_LIBDIR="$(dirname "$(g++ -print-file-name=libstdc++.so.6)")"
export LD_LIBRARY_PATH="$GCC_LIBDIR:${LD_LIBRARY_PATH:-}"

# Module-provided dependency roots
# Set HDF5_DIR only when needed, not globally.
#export HDF5_DIR="${TACC_HDF5_DIR:-/home1/apps/gcc14/openmpi5/phdf5/1.14.6}"

export BOOST_DIR="${TACC_BOOST_DIR:-/home1/apps/gcc14/boost/1.86.0}"
export BOOST_ROOT="$BOOST_DIR"

# Useful aliases for CMake/configure scripts
export CUDA_HOME="${TACC_CUDA_DIR:-}"
export CUDAToolkit_ROOT="${TACC_CUDA_DIR:-}"

python3 -V
