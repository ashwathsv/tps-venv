# Building TPS dependencies on frontera

## Create a venv

To create a virtual enviroment do the following:
```
source load_modules.sh
mkdir tps-venv
cd tps-venv/
python3 -m venv .
source bin/activate
```

## Install all dependencies

The following script should be used:
- `script.sh`: download, built, and locally install all c/c++ dependencies. It creates a file called `export_env` that defines useful enviromental variable.
- `install-git-lfs.sh`: [Optional] download and locally install `git lfs` (needed to check-out `tps`)
- `pip-install-deps.sh`: pip install all the needed libraries and builds `mpi4py` against our compiler. Note: I have installed `parla` dependencies but not `parla` itself 

Example
```
../script.sh #creates export_env
source ../install-git-lfs.sh
source ../pip-install-deps.sh
```

## Configure and build TPS

with chaning your working directory to `tps-venv`

### Install tps + boltzmann + tps-inputs

You would need access to tps, bte, and tps-intputs repos.
Verify that the system site packages are not installed
You can do this by confirming include-system-site-packages = false in the pyvenv.cfg file
```
source ../install-tps-bte.sh
```

### Install tps only

Make sure to set up the environment (this is also needed to run tps applications)
```
source bin/activate
source ../load_modules.sh
source export_env
```

Configure and build tps
```
cd tps
./bootstrap
mkdir build-gpu
cd build-gpu
../configure CUDA_ARCH=sm_75 --disable-valgrind --enable-gpu-cuda --enable-pybind11 --with-cuda=$CUDA_HOME
make -j 6
make -j 6 check TESTS="vpath.sh"
```

Note `make check` gets stuck on the compute note (I guess because of calls to `mpirun` that should be replaced by `ibrun`.
