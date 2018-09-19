PyCBC Live notes for O2 data replay - O3 investigation
======================================================

Preparing an environment for running PyCBC Live
-----------------------------------------------

Create new virtualenv with path `$VE` and activate it.

`pip install mpi4py ligo.gracedb lalsuite`

Create directory `$VE/src`.

Clone PyCBC into `$VE/src/pycbc` and `cd` into it.
Install PyCBC with `pip install .`.

Clone https://git.ligo.org/ligo-cbc/pycbc-config from your own user.

Move to `O3exp/pycbc_live` into the working copy (where this README is).
You will find a file `run.sh`, a file with a list of hosts to run MPI workers on,
and two FFTW wisdom files.

Copy the above files to `node550` under a directory in `/local/pycbc.live`
(*not* NFS), obviously as the `pycbc.live` user.


Starting PyCBC Live
-------------------

Make sure you are logged in as `pycbc.live`.

Make sure the appropriate virtualenv is active.

From `node550`, start `run.sh` redirecting the stdout and stderr to a file
also under `/local/pycbc.live` (*not* NFS).

Wait for the waveforms contained in the supplied template bank to be generated.

Before leaving the analysis running, make sure there are no exceptions
or errors in the log file and that the log is being populated with lots
of messages.
