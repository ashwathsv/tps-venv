#! /bin/bash

module purge
module load git/2.24.1 cmake/3.24.2 autotools/1.2 cuda/12.2  gcc/9.1.0 impi/19.0.9 python3/3.9.2 boost/1.86.0 phdf5/1.14.6

export HDF5_DIR=$TACC_HDF5_DIR
