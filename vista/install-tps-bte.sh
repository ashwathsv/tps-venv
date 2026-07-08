#!/bin/bash -x

ROOT_DIR=$(pwd)
make_cores=16

source load_modules.sh
source "$ROOT_DIR/tps-deps-gcc14-cuda12-ompi507/export_env"
export HDF5_DIR="${TACC_HDF5_DIR:-/home1/apps/gcc14/openmpi5/phdf5/1.14.6}"
source "$PYENV_DIR/bin/activate"

export LD_LIBRARY_PATH="$EXTRA_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"
export CC=mpicc
export CXX=mpicxx
export FC=mpifort

TPS_DIR="$ROOT_DIR/tps"
TPS_INPUTS_DIR="$TPS_DIR/tps-inputs"

cd "$TPS_DIR"
git clone git@github.com:pecos/tps.git
git checkout zetaf-bte
git branch

git clone git@github.com:ut-padas/boltzmann.git
git clone git@github.com:pecos/torch-chemistry.git
git clone git@github.com:pecos/tps-inputs.git
cd tps-inputs && git checkout lowmach-bte-bindings-cpp-call-python

cd "$TPS_INPUTS_DIR"
git checkout lowmach-bte-bindings-cpp-call-python

cd "$TPS_DIR"
./bootstrap

rm -rf build-cpu-zetafbte
mkdir -p build-cpu-zetafbte
cd build-cpu-zetafbte

unset PYTHONPATH

python -c "import mpi4py, h5py, pybind11; print('Python deps OK')"
python -c "import pybind11; print(pybind11.get_include())"

../configure \
  CC=mpicc \
  CXX=mpicxx \
  --disable-valgrind \
  --enable-pybind11 \
  CPPFLAGS="-I$(python -c 'import pybind11; print(pybind11.get_include())') -DHAVE_PYTHON -DHAVE_MPI4PY -I$CUDA_HOME/include" \
  LDFLAGS="-L$CUDA_HOME/lib64" \
  LIBS="-lcudart"

make -j "$make_cores"

ldd src/.libs/tps | grep -E 'libstdc|mpi|mfem|HYPRE|metis|grvy|masa|hdf5|cuda' || true

make -j "$make_cores" check TESTS="vpath.sh"