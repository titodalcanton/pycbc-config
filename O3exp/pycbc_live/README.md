# PyCBC Live notes for O2 data replay and pre-O3 data

`run.sh` is used for testing, O2 replay and processing of commissioning data between O2 and O3.

`run_ER13.sh` is used during ER13. The template bank for ER13 is available and documented
[here](https://git.ligo.org/soumen.roy/HybridBankResults/tree/master/ER13/H1L1/OptFlow).


## Preparing an environment for running PyCBC Live

Create new virtualenv with path `$VE` and activate it.

`pip install mpi4py ligo.gracedb lalsuite`

Create directory `$VE/src`.

Clone PyCBC into `$VE/src/pycbc` and `cd` into it.
Install PyCBC with `pip install .`.

Clone https://git.ligo.org/ligo-cbc/pycbc-config from your own user.

Move to `O3exp/pycbc_live` into the working copy (where this README is).
You will find a file `run.sh`, a file with a list of hosts to run MPI workers on,
and two FFTW wisdom files.

Copy the  `run.sh` and the list of hosts to `node742` under a directory in `/local/pycbc.live`
(*not* NFS), obviously as the `pycbc.live` user.
For testing, replace `pycbc.live` with your user (and see below).

You will need to edit `run.sh` to point to the wisdom files. These need to be
in a directory visible to all nodes (so they need to remain under `/home`)


## Starting and managing PyCBC Live in production mode (*not* for testing)

First of all, before touching anything related to the production analysis,
log into CIT's `node742` as `pycbc.live` and source the virtualenv where
all the software is installed (`~pycbc.live/production/O3exp/env`).

The production analysis is managed by [supervisord](http://supervisord.org/).
This utility simplifies starting and stopping the analysis, it takes care of
restarting it automatically if it goes down, and it logs all such events for
documentation. We have configured supervisord in the file
`~pycbc.live/production/O3exp/supervisord.conf` (have a look at that file
as it contains a few important paths). Supervisord can be controlled
with the following commands.

`supervisorctl -c ~pycbc.live/production/O3exp/supervisord.conf status`
displays the current status of the analysis.

`supervisorctl -c ~pycbc.live/production/O3exp/supervisord.conf start pycbclive`
starts the analysis if it is not running.

`supervisorctl -c ~pycbc.live/production/O3exp/supervisord.conf stop pycbclive`
stops a running analysis.

Sometimes supervisord itself needs to be (re)started, for instance after
`node742` is rebooted.

For more details, look at supervisord's documentation.

If you just started the analysis, before leaving, make sure there are no
exceptions or errors in the log file (i.e. the analysis stays up) and that
the stderr log file is being populated with lots of messages.

When operating on the production analysis, try to document all your findings
and actions, so as to make it easier for others to understand what happened
and what decisions were made (e.g. "I found the analysis was stuck with no
output on the logs, so I killed all the processes and restarted it").
A good place to report these notes is the PyCBC Slack, or the
[LIGO PyCBC wiki](https://www.lsc-group.phys.uwm.edu/ligovirgo/cbcnote/PyCBC/PyCBCLive).
If you find that you have to change the run script for some reason, you may
want to submit a merge request on this repository so the change is properly
documented.


## Testing and learning PyCBC Live

Here are a few notes on how to test PyCBC Live during development,
or for practicing if you are new to PyCBC Live. The most important things
to pay attention to during testing are the following:

* Do not interfere with the production analysis.
* Do not upload test triggers to GraceDB.

The steps below try to explain how to avoid both things.


### Get a working production script

Start from a production run script, typically the one from the most recent
observing or engineering run (`run.sh` in this directory is a good start
as I write these notes). Do *not* run the script as is, as you could
interfere with production analyses (although most likely you will just get
an error).


### Reduce number of MPI nodes

PyCBC Live uses MPI to distribute the trigger-generation operations across tens
of compute nodes. Typically you cannot run a second instance of PyCBC Live on
the same nodes: the resources are limited and the additional load will likely
cause the production analysis to fall behind.
When that happens, people will be notified of the problem.
Worst case, the production analysis might miss an event!

Most tests can still be done with a master node and a single worker node.
Thus, please reduce the number of nodes to 2 by changing `mpirun`'s option `-n`
to `2`, and use an MPI hosts file containing just the lines `localhost` and
`node550`. `node550` is reserved as a testing node so your test will not steal
resources from production nodes. The fewer nodes will also make the log
messages easier to follow.

In rare occasions, testing will require running on the full set of nodes for
brief periods of time.  Do *not* just run a test on the production nodes while
the production analysis is running.  Consider that you can use a different set
of nodes than the production ones (although there may be Condor jobs running on
them).  Most likely you should coordinate with the whole group, so at least the
production analysis can be taken down during the test without causing
surprises.


### Reduce the cost of the analysis

Running a production template bank with only 2 MPI nodes will generally not
work because of the required RAM and CPU time. This can be addressed in two
ways.

Change the template bank (`--bank-file` option) to one containing a small
number of templates (~1000 max). A tiny bank suitable for this purpose is
available at `~pycbc.live/production/O3exp/tiny.hdf`.

Another method is the `--size-override` option. This option takes as an
argument the number of nodes that you would normally use in production,
but will only run one worker process instead.

Note that although perfect for debugging, both of the options are *not*
suitable for doing sensitivity studies over the entire template bank parameter
space, as they will dramatically reduce the sensitivity of the search.


### Remove all mentions of X509

Remove all `export` commands mentioning `X509`. Remove all `X509` arguments from `-envlist`.

### Disable event uploads

When testing, make sure you disable the upload of production events to
GraceDB, and switch to the development instance `gracedb-playground`.
This is done by setting the options
```
--enable-gracedb-upload
--enable-single-detector-upload
--gracedb-server https://gracedb-playground.ligo.org/api/
```
and *removing* the option `--enable-production-gracedb-upload`.

Depending on what you are testing, you may actually want to disable GraceDB
uploads altogether, which is achieved simply by removing all options
mentioning `gracedb`.


### Save results to a local directory

Set `--output-path` to a directory you can write to. Ideally this directory
should *not* be on an NFS filesystem, so as to minimize the NFS load and
also to avoid latency and delays introduced by NFS slowness.


### Disable status file

Remove the option `--output-status` and its argument, or set the argument
to a file in a local filesystem.


### Disable state vector and DQ vector checks

Depending on what you are testing, you may want to disable the use of state
vector and DQ bits. This will most likely be the case, for instance,
if you are analyzing simulated strain data. Remove the options:

* `--state-channel`
* `--analyze-flags`
* `--data-quality-channel`
* `--data-quality-flags`
* `--data-quality-padding`

(and their arguments).


### Starting the analysis

The production analysis runs under the `pycbc.live` account and is started from
`node742` at CIT.  The `pycbc.live` user should *not* be used for testing; you
should start any test run from *your user*, after logging into `node742`. Using
your own account makes it easier for you to work and minimizes the chance of
your test interfering with or overwriting production results or logs.

Before running a test, make sure you can `ssh` from `node742` to any of the
compute nodes without a password. The first time you try this you will most
likely need to create an SSH keypair (unless you already have one) and then
add your SSH pubkey to your own `~/.ssh/authorized_keys` file. If `ssh node551`
brings you to `node551` without a password, most likely you are good to go.
