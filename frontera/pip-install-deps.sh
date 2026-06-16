mpi4py_ver=3.1.5
WDIR=$(pwd)
python --version
pip install --upgrade pip
pip install cython psutil scikit-build nvtx
pip install numpy scipy  matplotlib cupy-cuda12x numba multiprocess "pybind11[global]" lxcat_data_parser sympy
pip install h5py
pip install findiff

MPICC=$(command -v mpicc)
wget https://github.com/mpi4py/mpi4py/releases/download/$mpi4py_ver/mpi4py-$mpi4py_ver.tar.gz \
&& tar -zxf mpi4py-$mpi4py_ver.tar.gz && cd mpi4py-$mpi4py_ver \
&& python setup.py build --mpicc=$MPICC && python setup.py install
cd $WDIR

git clone git@github.com:ut-parla/parla-experimental.git
cd parla-experimental
git submodule update --init --recursive
CC=gcc CXX=g++ make all -j4

cd $WDIR
# pip install --extra-index-url=https://pypi.nvidia.com cudf-cu12==24.2.* cuml-cu12==24.2.*



