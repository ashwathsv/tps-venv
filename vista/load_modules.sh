#!/bin/bash
#set -e

LOAD_MODULES_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

module purge
ml TACC cmake/3.31.5 ucc ucx xalt nvidia nvidia_math gcc/13.2.0 cuda/12.5 python3/3.11.8 openmpi/5.0.5 phdf5/1.14.6
# ml gcc/14.2.0 cuda/12.8 openmpi/5.0.5_nvc249 python3/3.11.8 phdf5/1.14.6 cmake/3.31.5 nvidia_math/12.4

# SETTING SOME FLAGS FOR ucx TO DISABLE x86 OPTIMIZATION FLAGS THAT ARE NOT COMPATIBLE WITH arm CPUs
# export UCX_TLS=rc,sm,self
# export UCX_MEMTYPE_CACHE=n

# SET FLAG FOR DETAILED DEBUG OUTPUT FOR ucx (USE THIS FOR DEBUGGING)
# export UCX_LOG_LEVEL=debug

# export TACC_BOOST_DIR=/opt/apps/intel19/python3_9/boost/1.72
# export TACC_BOOST_LIB=/opt/apps/intel19/python3_9/boost/1.72/lib
# export TACC_BOOST_INC=/opt/apps/intel19/python3_9/boost/1.72/include
# export TACC_BOOST_BIN=/opt/apps/intel19/python3_9/boost/1.72/bin
# export BOOST_ROOT=/opt/apps/intel19/python3_9/boost/1.72
# export BOOST_ROOT=$TACC_BOOST_DIR

#Preset python path for the future
# export PATH=$LOAD_MODULES_SCRIPT_DIR/tps-env/.python/bin:/opt/apps/gcc14/cuda12/python3/3.11.8/bin:$PATH
# export LD_LIBRARY_PATH=$LOAD_MODULES_SCRIPT_DIR/tps-env/.python/lib:/opt/apps/gcc14/cuda12/python3/3.11.8/lib:$LD_LIBRARY_PATH
python3 -V
