#!/bin/bash -x
#set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
ROOT_DIR=$(pwd)

PYENV_DIR=$ROOT_DIR/py-venv-gcc14-ompi507
INSTALL_DIR=$ROOT_DIR/tps-deps-gcc14-cuda12-ompi507
WDIR=$ROOT_DIR/build-gcc14-cuda12-ompi507

make_cores=32
cuda_arch=sm_90

source "$SCRIPT_DIR/load_modules.sh"
module list

#export CC=mpicc
#export CXX=mpicxx
#export FC=mpifort
#export F77=mpifort
#export LD_LIBRARY_PATH="$(dirname "$(g++ -print-file-name=libstdc++.so.6)"):$LD_LIBRARY_PATH"

#export HDF5_DIR=/home1/apps/gcc14/openmpi5/phdf5/1.14.6
#export BOOST_DIR=/home1/apps/gcc14/boost/1.86.0

echo "Compiler/MPI checks"
which gcc g++ mpicc mpicxx mpirun prterun cmake python3
gcc --version
g++ --version
mpicxx --showme:link
h5pcc -show
g++ -print-file-name=libstdc++.so.6
strings "$(g++ -print-file-name=libstdc++.so.6)" | grep -E 'GLIBCXX_3.4.32|CXXABI_1.3.15'

rm -rf "$WDIR" "$INSTALL_DIR" "$PYENV_DIR"
mkdir -p "$WDIR" "$INSTALL_DIR"

python3 -m venv "$PYENV_DIR"
source "$PYENV_DIR/bin/activate"
python3 -V

# MASA
cd "$WDIR"
export MASA_DIR=$INSTALL_DIR
git clone https://github.com/dreamer2368/MASA.git masa
cd masa
git checkout 887d5e26e3865bd6415503d62f9a557bbd3da4dc
./bootstrap && CC=gcc CXX=g++ ./configure --prefix=$MASA_DIR
make -j "$make_cores"
make install

# GRVY
cd "$WDIR"
export GRVY_DIR=$INSTALL_DIR
wget https://github.com/hpcsi/grvy/releases/download/0.38.0/grvy-0.38.0.tar.gz
tar xfz grvy-0.38.0.tar.gz
cd grvy-0.38.0
./configure CXXFLAGS="-std=c++11" --prefix=$GRVY_DIR  --enable-boost-headers-only
make -j "$make_cores"
make install
#rm -f "$GRVY_DIR"/lib/*.la "$GRVY_DIR"/lib/*.a

# GSLIB
cd "$WDIR"
gslib_ver=1.0.7
export GSLIB_DIR=$INSTALL_DIR
wget https://github.com/Nek5000/gslib/archive/refs/tags/v${gslib_ver}.tar.gz
tar xvf v${gslib_ver}.tar.gz
cd gslib-${gslib_ver}
make -j "$make_cores" CC=mpicc CFLAGS="-O3 -fPIC" DESTDIR="$GSLIB_DIR"

# HYPRE
cd "$WDIR"
export HYPRE_DIR=$INSTALL_DIR
export HYPRE_INC=$HYPRE_DIR/include
export HYPRE_LIB=$HYPRE_DIR/lib
wget  https://github.com/hypre-space/hypre/archive/refs/tags/v2.26.0.tar.gz \
    && tar -zxvf v2.26.0.tar.gz \
    && cd hypre-2.26.0/src/ \
    && CC=mpicc CXX=mpicxx ./configure --enable-shared --disable-fortran --prefix=$HYPRE_DIR \
    && make -j ${make_cores} \
    && make check \
    && make install
cd $ROOT_DIR

# METIS
cd "$WDIR"
export METIS_DIR=$INSTALL_DIR
wget https://karypis.github.io/glaros/files/sw/metis/metis-5.1.0.tar.gz
tar -xvf metis-5.1.0.tar.gz
cd metis-5.1.0
export CMAKE_POLICY_VERSION_MINIMUM=3.5
make config prefix="$METIS_DIR" shared=1
make -j "$make_cores"
make install

# MFEM
cd "$WDIR"
mfem_ver=4.8
export MFEM_DIR=$INSTALL_DIR
wget https://github.com/mfem/mfem/archive/refs/tags/v${mfem_ver}.tar.gz
tar xvf v${mfem_ver}.tar.gz
cd mfem-${mfem_ver}
unset MFEM_DIR || true

make parallel \
  PREFIX="$INSTALL_DIR" \
  MFEM_DEBUG=NO \
  STATIC=NO \
  SHARED=YES \
  HYPRE_OPT="-I$HYPRE_INC" \
  HYPRE_LIB="-L$HYPRE_LIB -lHYPRE" \
  MFEM_USE_METIS_5=YES \
  METIS_OPT="-I$METIS_DIR/include" \
  METIS_LIB="-L$METIS_DIR/lib -lmetis" \
  MFEM_USE_GSLIB=YES \
  GSLIB_OPT="-I$GSLIB_DIR/include" \
  GSLIB_LIB="-L$GSLIB_DIR/lib -lgs" \
  -j "$make_cores"

cd examples
make -j "$make_cores"
cd ..

make install
export MFEM_DIR=$INSTALL_DIR
export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"

# Post-build checks
echo "Post-build library checks"

for lib in \
  "$INSTALL_DIR/lib/libmasa.so" \
  "$INSTALL_DIR/lib/libgrvy-0.38.so" \
  "$INSTALL_DIR/lib/libHYPRE.so" \
  "$INSTALL_DIR/lib/libmetis.so" \
  "$INSTALL_DIR/lib/libgs.so" \
  "$INSTALL_DIR/lib/libmfem.so.4.8"
do
  if [ -e "$lib" ]; then
    echo "==== $lib ===="
    ldd "$lib" | grep -E 'libstdc|mpi|hdf5|HYPRE|metis|gs|openmpi' || true
  fi
done

# Environment export file
cat > "$INSTALL_DIR/export_env" <<EOF
export TPS_DEPS=$INSTALL_DIR
export PYENV_DIR=$PYENV_DIR
export MASA_DIR=$INSTALL_DIR
export GRVY_DIR=$INSTALL_DIR
export GSLIB_DIR=$INSTALL_DIR
export HYPRE_DIR=$INSTALL_DIR
export METIS_DIR=$INSTALL_DIR
export MFEM_DIR=$INSTALL_DIR
export HDF5_DIR=$HDF5_DIR
export BOOST_DIR=$BOOST_DIR
export CUDA_HOME=$TACC_CUDA_DIR
export cuda_arch=$cuda_arch
export EXTRA_LD_LIBRARY_PATH=$INSTALL_DIR/lib:$(dirname "$(g++ -print-file-name=libstdc++.so.6)")
EOF

echo "Done."
echo "Dependency prefix: $INSTALL_DIR"
echo "Python venv:       $PYENV_DIR"
