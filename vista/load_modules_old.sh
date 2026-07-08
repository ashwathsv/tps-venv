#!/bin/bash
#set -e

LOAD_MODULES_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

module purge
#ml load TACC cmake ucc ucx xalt nvidia nvidia_math cuda openmpi/5.0.5
#ml gcc/14.2.0 cuda/13.1 openmpi/5.0.8 cmake python3/3.11.8 phdf5/1.14.6 boost/1.86.0
#ml TACC cmake/3.31.5 ucc ucx xalt nvidia nvidia_math gcc/13.2.0 cuda/12.5 python3/3.11.8 openmpi/5.0.5 phdf5/1.14.6 boost/1.86.0
#ml TACC cmake/3.31.5 ucc ucx xalt nvidia nvidia_math gcc/14.2.0 cuda/12.5 python3/3.11.8 openmpi/5.0.7 phdf5/1.14.6 boost/1.86.0
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
#module unload xalt # new addition based on TACC ticket

#export CC=mpicc
#export CXX=mpicxx
#export FC=mpifort
#export LD_LIBRARY_PATH=$(dirname $(g++ -print-file-name=libstdc++.so.6)):$LD_LIBRARY_PATH

# export TACC_BOOST_DIR=/opt/apps/intel19/python3_9/boost/1.72
# export TACC_BOOST_LIB=/opt/apps/intel19/python3_9/boost/1.72/lib
# export TACC_BOOST_INC=/opt/apps/intel19/python3_9/boost/1.72/include
# export TACC_BOOST_BIN=/opt/apps/intel19/python3_9/boost/1.72/bin
# export BOOST_ROOT=/opt/apps/intel19/python3_9/boost/1.72
# export BOOST_ROOT=$TACC_BOOST_DIR
#export HDF5_DIR=$TACC_HDF5_DIR

#Preset python path for the future
#export PATH=$LOAD_MODULES_SCRIPT_DIR/tps-env/.python/bin:/opt/apps/gcc14/cuda12/python3/3.11.8/bin:$PATH
#export LD_LIBRARY_PATH=$LOAD_MODULES_SCRIPT_DIR/tps-env/.python/lib:/opt/apps/gcc14/cuda12/python3/3.11.8/lib:$LD_LIBRARY_PATH
python3 -V
