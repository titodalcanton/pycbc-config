PyCBC Live notes for O2 data replay - O3 investigation
======================================================

Preparing an environment for running PyCBC Live
-----------------------------------------------

Create new virtualenv with path `$VE` and activate it.

`pip install mpi4py ligo.gracedb lalsuite`

Create directory `$VE/src`.

Download FFTW 3.3.8 into `$VE/src`.
Configure FFTW *disabling AVX512 optimizations* and setting the prefix to `$VE`.
Build and install FFTW
This has to be repeated twice, once for single precision (`--enable-float`) and once for double

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

Clone PyCBC into `$VE/src/pycbc`.
Move into PyCBC directory and run `pip install .`.

Clone https://git.ligo.org/ligo-cbc/pycbc-config (probably in your own home).

Move to `O3exp/pycbc_live` into the working copy. You will find a file `run.sh`
and a file with a list of hosts to run MPI workers on.

Copy both files to `node550` under a directory in `/local/pycbc.live`
(*not* NFS).

Starting PyCBC Live
-------------------

From `node550`, start `run.sh` redirecting the stdout and stderr to a file
also under `/local/pycbc.live` (*not* NFS).

Wait for the template bank to be generated.
