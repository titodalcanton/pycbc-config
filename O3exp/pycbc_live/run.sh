#!/bin/bash

# PyCBC Live startup script during O2 data replay

export LAL_DATA_PATH=/home/pycbc.live/production/O3exp/
export X509_USER_PROXY=/home/pycbc.live/.globus/proxy
export X509_USER_CERT=/home/pycbc.live/.globus/robot.cert.pem
export X509_USER_KEY=/home/pycbc.live/.globus/robot.cert.key
export OMP_NUM_THREADS=4

mpirun \
-hostfile mpi_hosts_cit.txt \
-n 80 \
-ppn 1 \
-envlist X509_USER_PROXY,X509_USER_KEY,X509_USER_CERT,PYTHONPATH,LD_LIBRARY_PATH,OMP_NUM_THREADS,VIRTUAL_ENV,PATH,LAL_DATA_PATH \
\
python -m mpi4py `which pycbc_live` \
--bank-file /home/pycbc.live/production/O3exp/o2bank_v1.hdf \
--sample-rate 2048 \
--enable-bank-start-frequency \
--low-frequency-cutoff 20 \
--max-length 256 \
--approximant "SPAtmplt:mtotal<4" "SEOBNRv4_ROM:else" \
--chisq-bins "0.9 * get_freq('fSEOBNRv4Peak',params.mass1,params.mass2,params.spin1z,params.spin2z) ** (2.0 / 3.0)" \
--snr-abort-threshold 50000 \
--snr-threshold 4.5 \
--newsnr-threshold 4.0 \
--max-triggers-in-batch 25 \
--store-loudest-index 50 \
--analysis-chunk 8 \
--autogating-threshold 200 \
--highpass-frequency 13 \
--highpass-bandwidth 5 \
--highpass-reduction 200 \
--psd-samples 30 \
--max-psd-abort-distance 300 \
--min-psd-abort-distance 20 \
--psd-abort-difference .15 \
--psd-recalculate-difference .01 \
--psd-inverse-length 3.5 \
--psd-segment-length 4 \
--trim-padding .5 \
--store-psd \
--state-channel H1:GDS-CALIB_STATE_VECTOR L1:GDS-CALIB_STATE_VECTOR V1:DQ_ANALYSIS_STATE_VECTOR \
--channel-name H1:GDS-CALIB_STRAIN_O2Replay L1:GDS-CALIB_STRAIN_O2Replay V1:Hrec_hoft_16384Hz_O2Replay \
--increment-update-cache H1:/dev/shm/kafka/H1_O2/ L1:/dev/shm/kafka/L1_O2/ V1:/dev/shm/kafka/V1_O2/ \
--frame-src H1:/dev/shm/kafka/H1_O2/* L1:/dev/shm/kafka/L1_O2/* V1:/dev/shm/kafka/V1_O2/* \
--processing-scheme cpu:4 \
--fftw-measure-level 0 \
--fftw-threads-backend openmp \
--fftw-input-float-wisdom-file fftw_wisdom_single_cit \
--fftw-input-double-wisdom-file fftw_wisdom_double_cit \
--increment 8 \
--single-newsnr-threshold 10 \
--single-duration-threshold 1.0 \
--single-fixed-ifar .06 \
--single-reduced-chisq-threshold 5.0 \
--analyze-flags SCIENCE_INTENT \
--verbose \
--max-batch-size 16777216 \
--frame-read-timeout 100 \
--output-path ./data \
--output-status /home/pycbc.live/public_html/production/status.json \
--day-hour-output-prefix \
--background-statistic phasetd_newsnr \
--background-statistic-files /home/pycbc.live/production/O3exp/H1L1-PHASE_TIME_AMP_v1.hdf \
--enable-background-estimation \
--background-ifar-limit 100 \
--timeslide-interval 0.1 \
--ifar-upload-threshold 0.003 \
--enable-gracedb-upload \
--enable-production-gracedb-upload \
--enable-single-detector-upload \
--gracedb-server https://gracedb-playground.ligo.org/api/ \
--round-start-time 4 \
--followup-detectors V1 \
--enable-single-detector-background
