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
uv pip install numpy scipy sympy matplotlib cupy-cuda12x numba multiprocess "pybind11[global]" lxcat_data_parser
CFLAGS=-noswitcherror uv pip install mpi4py
uv pip install h5py

#MPICC=$(command -v mpicc)
#MPICXX=$(command -v mpicxx)
#cd $WDIR
#wget https://github.com/mpi4py/mpi4py/releases/download/$mpi4py_ver/mpi4py-$mpi4py_ver.tar.gz \
#&& rm -rf  mpi4py-$mpi4py_ver && tar -zxf mpi4py-$mpi4py_ver.tar.gz && cd mpi4py-$mpi4py_ver \
#&& python setup.py build --mpicc=$MPICC && python setup.py install
#cd $ROOT_DIR

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
