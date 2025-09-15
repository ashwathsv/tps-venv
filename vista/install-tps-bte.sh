#!/bin/bash -x
ROOT_DIR=$(pwd)
make_cores=16

source load_modules.sh
source tps-env/bin/activate
source tps-env/export_env

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$EXTRA_LD_LIBRARY_PATH

TPS_DIR=$ROOT_DIR/tps
git clone git@github.com:pecos/tps.git
cd $TPS_DIR && git checkout lowmach-bte-bindings

git clone git@github.com:ut-padas/boltzmann.git
git clone git@github.com:pecos/tps-inputs.git
cd tps-inputs && git checkout lowmach-bte-bindings

cd $TPS_DIR
git branch 
./bootstrap
mkdir -p build-cpu-low-mach
cd build-cpu-low-mach
../configure CC=mpicc CXX=mpicxx --disable-valgrind --enable-pybind11 CPPFLAGS="-DPyMPI_HAVE_MPI_Session -I$(python3 -c "import pybind11; print(pybind11.get_include())")"

# mkdir build-gpu
# cd build-gpu
# ../configure CC=mpicc CXX=mpicxx CUDA_ARCH=$cuda_arch --disable-valgrind --enable-gpu-cuda --enable-pybind11 --with-cuda=$CUDA_HOME CPPFLAGS=-I$(python3 -c "import pybind11; print(pybind11.get_include())")
make -j $make_cores
make -j $make_cores  check TESTS="vpath.sh"
