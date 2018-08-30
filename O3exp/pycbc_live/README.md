PyCBC Live notes for O2 data replay - O3 investigation
======================================================

Preparing an environment for running PyCBC Live
-----------------------------------------------

Create new virtualenv with path `$VE` and activate it.

`pip install mpi4py ligo.gracedb lalsuite`

Create directory `$VE/src`.

Due to a bug, the system build of FFTW will not work for PyCBC Live and will
lead to random hangs of the analysis.  Download FFTW 3.3.8 into `$VE/src`.
Configure FFTW *disabling AVX512 optimizations* and setting the prefix to
`$VE`, then build and install FFTW. Note that this has to be repeated twice,
once for single precision (`--enable-float`) and once for double.  You can use
the following commands:
```
export CC=/opt/rh/devtoolset-7/root/usr/bin/gcc

# double-precision version

./configure \
    --enable-shared \
    --enable-fma \
    --enable-threads \
    --enable-openmp \
    --enable-avx2 \
    --enable-avx \
    --enable-sse2 \
    --prefix=$VE
make -j
make install

make clean

# single-precision version

./configure \
    --enable-shared \
    --enable-fma \
    --enable-threads \
    --enable-openmp \
    --enable-avx2 \
    --enable-avx \
    --enable-sse2 \
    --enable-float \
    --prefix=$VE
make -j
make install
```
Note that FFTW should be built on one of the worker hosts, e.g. `node550`.

Clone PyCBC into `$VE/src/pycbc` and `cd` into it.
Install PyCBC with `pip install .`.

Clone https://git.ligo.org/ligo-cbc/pycbc-config from your own user.

Move to `O3exp/pycbc_live` into the working copy (where this README is).
You will find a file `run.sh` and a file with a list of hosts to run MPI workers on.

Copy both files to `node550` under a directory in `/local/pycbc.live`
(*not* NFS), obviously as the `pycbc.live` user.

Starting PyCBC Live
-------------------

Make sure you are logged in as `pycbc.live`.

From `node550`, start `run.sh` redirecting the stdout and stderr to a file
also under `/local/pycbc.live` (*not* NFS).

Wait for the template bank to be generated.

Before leaving the analysis running, make sure there are no exceptions
or errors in the log file and that the log is being populated with lots
of messages.
