#!/bin/bash -x
ROOT_DIR=$(pwd)
make_cores=16

source load_modules.sh
source tps-env/bin/activate
source tps-env/export_env

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$EXTRA_LD_LIBRARY_PATH

TPS_DIR=$ROOT_DIR/tps
# git clone git@github.com:pecos/tps.git
cd $TPS_DIR && git checkout zetaf-bte
# cd $TPS_DIR && git checkout boltzmann-integration

git clone git@github.com:ut-padas/boltzmann.git
git clone git@github.com:pecos/torch-chemistry.git
git clone git@github.com:pecos/tps-inputs.git
cd tps-inputs && git checkout lowmach-bte-bindings-cpp-call-python


cd $TPS_DIR
git branch 
./bootstrap
mkdir -p build-cpu-zetafbte
cd build-cpu-zetafbte
# We need below command to ensure TPS configure script uses the virtual environment python 
#(located in /scratch or /work unlike system wide Python which is usualy in /opt)
unset PYTHONPATH
#python -c "import mpi4py; print(mpi4py.__file__)" # Use this command to verify the Python path

#../configure CC=mpicc CXX=mpicxx --disable-valgrind --enable-pybind11 CPPFLAGS=-I$(python3 -c "import pybind11; print(pybind11.get_include())")
#../configure CC=mpicc CXX=mpicxx --disable-valgrind --enable-pybind11 CPPFLAGS="-I$(python3 -c "import pybind11; print(pybind11.get_include())") -DHAVE_PYTHON -DHAVE_MPI4PY"
../configure CC=mpicc CXX=mpicxx --disable-valgrind --enable-pybind11 CPPFLAGS="-I$(python3 -c "import pybind11; print(pybind11.get_include())") -DHAVE_PYTHON -DHAVE_MPI4PY -I$CUDA_HOME/include" LDFLAGS="-L$CUDA_HOME/lib64 -lcudart"
# mkdir build-gpu
# cd build-gpu
# ../configure CC=mpicc CXX=mpicxx CUDA_ARCH=$cuda_arch --disable-valgrind --enable-gpu-cuda --enable-pybind11 --with-cuda=$CUDA_HOME CPPFLAGS=-I$(python3 -c "import pybind11; print(pybind11.get_include())")
make -j $make_cores
make -j $make_cores  check TESTS="vpath.sh"
