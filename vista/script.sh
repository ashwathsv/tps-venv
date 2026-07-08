#!/bin/bash -x
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(pwd)
INSTALL_DIR=$ROOT_DIR/tps-env
WDIR=$ROOT_DIR/build
make_cores=32
cuda_arch=sm_90

set -e

source $SCRIPT_DIR/load_modules.sh
module list

#export CC=mpicc
#export CXX=mpicxx
#export FC=mpifort
#export F77=mpifort
#export LD_LIBRARY_PATH=$(dirname $(g++ -print-file-name=libstdc++.so.6)):$LD_LIBRARY_PATH

rm -rf $WDIR
rm -rf $INSTALL_DIR

mkdir $WDIR
mkdir $INSTALL_DIR

# #source $SCRIPT_DIR/install-python.sh
python3 -V
python3 -m venv tps-env $INSTALL_DIR

# MASA LOCAL INSTALL
cd $WDIR
export MASA_DIR=$INSTALL_DIR
git clone https://github.com/dreamer2368/MASA.git masa
cd masa && git checkout 887d5e26e3865bd6415503d62f9a557bbd3da4dc
./bootstrap && CC=gcc CXX=g++ ./configure --prefix=$MASA_DIR && make -j ${make_cores} && make install
cd $ROOT_DIR

# BOOST commands are temporarily commented to see if we can build without
#export BOOST_DIR=$INSTALL_DIR
#cd $WDIR
#wget https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.gz
#tar xfz boost_1_87_0.tar.gz
#cp -r boost_1_87_0/boost $BOOST_DIR/include
#cd $ROOT_DIR
#export BOOST_LIB_VERSION=187

#GRVY builds
export GRVY_DIR=$INSTALL_DIR
cd $WDIR
wget https://github.com/hpcsi/grvy/releases/download/0.38.0/grvy-0.38.0.tar.gz
tar xfz grvy-0.38.0.tar.gz
cd grvy-0.38.0
./configure CXXFLAGS="-std=c++11" --prefix=$GRVY_DIR  --enable-boost-headers-only && make -j ${make_cores} && make install
rm -rf $GRVY_DIR/lib/*.la $GRVY_DIR/lib/*.a
cd $ROOT_DIR

#GSLIB builds
cd $WDIR
gslib_ver="1.0.7"
export GSLIB_DIR=$INSTALL_DIR
wget https://github.com/Nek5000/gslib/archive/refs/tags/v$gslib_ver.tar.gz
tar xvf v$gslib_ver.tar.gz
cd gslib-$gslib_ver \
    && make -j ${make_cores} CC=mpicc CFLAGS="-O3 -fPIC" DESTDIR=$GSLIB_DIR
cd $ROOT_DIR

#HYPRE builds
cd $WDIR
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

#METIS builds when the CMAKE_POLICY_VERION_MINIMUM is added
# cd $WDIR
# export METIS_DIR=$INSTALL_DIR
# wget https://karypis.github.io/glaros/files/sw/metis/metis-5.1.0.tar.gz
# tar -xvf metis-5.1.0.tar.gz
# cd metis-5.1.0 && \
#     export CMAKE_POLICY_VERSION_MINIMUM=3.5 && \
#     make config prefix=$METIS_DIR shared=1 && \
#     make -j ${make_cores} && make install
# cd $ROOT_DIR

cd $WDIR
export METIS_DIR=$INSTALL_DIR
wget https://karypis.github.io/glaros/files/sw/metis/metis-5.1.0.tar.gz
tar -xvf metis-5.1.0.tar.gz
cd metis-5.1.0 && \
    make config prefix=$METIS_DIR shared=1 && \
    make -j ${make_cores} && make install
cd $ROOT_DIR

# We will use the system provided phdf5 instead of this
#cd $WDIR
#export HDF5_DIR=$INSTALL_DIR
#wget https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_12_2/source/hdf5-1.12.2.tar.gz
#tar -xvf hdf5-1.12.2.tar.gz
#cd hdf5-1.12.2 && \
#CC=mpicc ./configure --enable-parallel --prefix=$INSTALL_DIR && \
#make -j ${make_cores} && make install
#cd $ROOT_DIR

cd $WDIR
mfem_ver="4.8"
mfem_prefix=$INSTALL_DIR
wget https://github.com/mfem/mfem/archive/refs/tags/v$mfem_ver.tar.gz && tar xvf v$mfem_ver.tar.gz

# cd mfem-$mfem_ver \
#     && unset MFEM_DIR \
#     && make pcuda CUDA_ARCH=${cuda_arch} PREFIX=$mfem_prefix \
#        MFEM_DEBUG=NO STATIC=NO SHARED=YES \
#        HYPRE_OPT="-I$HYPRE_INC" HYPRE_LIB="-L$HYPRE_LIB -lHYPRE -L$TACC_NVIDIA_LIB -L$TACC_NVIDIA_MATH_LIB -L$TACC_CUDA_LIB -lcusolver -lcusparse -lcurand -lcublas" \
#        MFEM_USE_METIS_5=YES METIS_OPT="-I$METIS_DIR/include" METIS_LIB="-L$METIS_DIR/lib -lmetis" \
#        MFEM_USE_GSLIB=YES GSLIB_OPT="-I$GSLIB_DIR/include" GSLIB_LIB="-L$GSLIB_DIR/lib -lgs" -j ${make_cores}\
#        && cd examples && make -j ${make_cores} && cd .. && make install
# cd $ROOT_DIR
# export MFEM_DIR=$mfem_prefix

cd mfem-$mfem_ver && unset MFEM_DIR 
make parallel PREFIX=$mfem_prefix\
    MFEM_DEBUG=NO STATIC=NO SHARED=YES\
    HYPRE_OPT="-I$HYPRE_INC"\
    HYPRE_LIB="-L$HYPRE_LIB -lHYPRE" \
    MFEM_USE_METIS_5=YES METIS_OPT="-I$METIS_DIR/include" METIS_LIB="-L$METIS_DIR/lib -lmetis"\
    MFEM_USE_GSLIB=YES GSLIB_OPT="-I$GSLIB_DIR/include" GSLIB_LIB="-L$GSLIB_DIR/lib -lgs" -j ${make_cores}

cd examples && make -j ${make_cores} && cd .. 

cd $WDIR
cd mfem-$mfem_ver
make install

cd $ROOT_DIR
export MFEM_DIR=$mfem_prefix
# able to build and install MFEM libs with GCC + OpenMPI toolchain (see load_modules.sh for module list)

# Copy the phdf5 files from /home1 to INSTALL_DIR
cp /home1/apps/gcc14/openmpi5/phdf5/1.14.6/include/*.h $INSTALL_DIR/include
cp /home1/apps/gcc14/openmpi5/phdf5/1.14.6/lib/*.so $INSTALL_DIR/lib
cp /home1/apps/gcc14/openmpi5/phdf5/1.14.6/lib/*.so* $INSTALL_DIR/lib

cd $INSTALL_DIR
echo export MASA_DIR=$MASA_DIR > export_env
#echo export BOOST_DIR=$BOOST_DIR >> export_env # BOOST is loaded as a module
echo export GRVY_DIR=$GRVY_DIR >> export_env
echo export GSLIB_DIR=$GSLIB_DIR >> export_env
echo export HYPRE_DIR=$HYPRE_DIR >> export_env
echo export METIS_DIR=$METIS_DIR >> export_env
echo export MFEM_DIR=$MFEM_DIR >> export_env
echo export HDF5_DIR=$TACC_HDF5_DIR >> export_env
echo export CUDA_HOME=$TACC_CUDA_DIR >> export_env
echo export cuda_arch=$cuda_arch >> export_env
echo export EXTRA_LD_LIBRARY_PATH=$INSTALL_DIR/lib >> export_env

cd $ROOT_DIR

