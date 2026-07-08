#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(pwd)"
WDIR="$ROOT_DIR/build-python-gcc14-ompi507"
make_cores=6
mpi4py_ver=3.1.5

source "$SCRIPT_DIR/load_modules.sh"
source "$ROOT_DIR/tps-deps-gcc14-cuda12-ompi507/export_env"
source "$PYENV_DIR/bin/activate"

mkdir -p "$WDIR"

export LD_LIBRARY_PATH="$EXTRA_LD_LIBRARY_PATH:${LD_LIBRARY_PATH:-}"

MPICC="$(command -v mpicc)"
MPICXX="$(command -v mpicxx)"

python --version
python -m pip install --upgrade pip
python -m pip install uv

uv pip install \
  cython==0.29.37 \
  psutil \
  scikit-build \
  nvtx \
  numpy \
  scipy \
  sympy \
  matplotlib \
  cupy-cuda12x \
  numba \
  multiprocess \
  "pybind11[global]" \
  lxcat_data_parser \
  findiff

# mpi4py pinned to 3.1.5, built against current OpenMPI
cd "$WDIR"
rm -rf "mpi4py-$mpi4py_ver" "mpi4py-$mpi4py_ver.tar.gz"
# wget "https://github.com/mpi4py/mpi4py/releases/download/$mpi4py_ver/mpi4py-$mpi4py_ver.tar.gz"
# tar -zxf "mpi4py-$mpi4py_ver.tar.gz"
# cd "mpi4py-$mpi4py_ver"

# export MPICC="$(command -v mpicc)"

# python -m pip uninstall -y mpi4py || true
# MPICC="$MPICC" python -m pip install --no-binary=mpi4py --no-cache-dir "mpi4py==3.1.5"

MPICC=$(command -v mpicc)
wget https://github.com/mpi4py/mpi4py/releases/download/$mpi4py_ver/mpi4py-$mpi4py_ver.tar.gz \
&& tar -zxf mpi4py-$mpi4py_ver.tar.gz && cd mpi4py-$mpi4py_ver \
&& python setup.py build --mpicc=$MPICC && python setup.py install
cd $WDIR

# h5py built against Vista phdf5
export CC="$MPICC"
export HDF5_MPI=ON
export HDF5_DIR="${TACC_HDF5_DIR:-/home1/apps/gcc14/openmpi5/phdf5/1.14.6}"

python -m pip uninstall -y h5py || true
CC="$MPICC" HDF5_MPI=ON HDF5_DIR="$HDF5_DIR" \
python -m pip install --no-binary=h5py --no-cache-dir --no-deps h5py

python - <<'PY'
import cupy
import mpi4py
import h5py
print("cupy OK")
print("mpi4py OK:", mpi4py.__version__)
print(h5py.version.info)
PY

# Parla
cd "$WDIR"
rm -rf parla-experimental
git clone git@github.com:ut-parla/parla-experimental.git
cd parla-experimental
git submodule update --init --recursive

CC="$MPICC" CXX="$MPICXX" make all -j "$make_cores"

python -c "import parla; print('parla OK')"

cd "$ROOT_DIR"
echo "Python dependency install complete."