SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(pwd)
INSTALL_DIR=$ROOT_DIR/tps-env
WDIR=$ROOT_DIR/build
make_cores=6

set -e

source $SCRIPT_DIR/load_modules.sh
source $INSTALL_DIR/bin/activate 
source $INSTALL_DIR/export_env

mpi4py_ver=3.1.5
python --version
pip install --upgrade pip
pip install uv
uv pip install cython==0.29.37 psutil scikit-build nvtx
uv pip install numpy scipy sympy matplotlib cupy-cuda12x numba multiprocess "pybind11[global]" lxcat_data_parser findiff
CFLAGS=-noswitcherror uv pip install mpi4py
uv pip install h5py

MPICC=$(command -v mpicc)
wget https://github.com/mpi4py/mpi4py/releases/download/$mpi4py_ver/mpi4py-$mpi4py_ver.tar.gz \
&& tar -zxf mpi4py-$mpi4py_ver.tar.gz && cd mpi4py-$mpi4py_ver \
&& python setup.py build --mpicc=$MPICC && python setup.py install
cd $WDIR

# Building h5py so that it uses the same phdf5 available on Vista
export CC=mpicc
export HDF5_MPI="ON"
export HDF5_DIR=/home1/apps/gcc14/openmpi5/phdf5/1.14.6

pip uninstall h5py -y
pip install --no-binary=h5py --no-cache-dir h5py
# Use python -c "import h5py; print(h5py.version.info)" to verify that h5py is built with the same phdf5 version which is loaded
# This install changes mpi4py version from 3.1.5 to 4.1.2. Need to check if TPS + BTE build with this

# MPICC=$(command -v mpicc)
# MPICXX=$(command -v mpicxx)
# cd $WDIR
# wget https://github.com/mpi4py/mpi4py/releases/download/$mpi4py_ver/mpi4py-$mpi4py_ver.tar.gz \
# && rm -rf  mpi4py-$mpi4py_ver && tar -zxf mpi4py-$mpi4py_ver.tar.gz && cd mpi4py-$mpi4py_ver \
# && python setup.py build --mpicc=$MPICC && python setup.py install
# cd $ROOT_DIR

python -c "import cupy"
python -c "import mpi4py"

cd $WDIR
rm -rf parla-experimental
git clone git@github.com:ut-parla/parla-experimental.git
cd parla-experimental
git submodule update --init --recursive
CC=$MPICC CXX=$MPICXX make all -j ${make_cores}
cd $ROOT_DIR
python -c "import parla"

#pip install --verbose --extra-index-url=https://pypi.nvidia.com cudf-cu11==24.2.* cuml-cu11==24.2.*
