#!/bin/bash

# PyCBC Live startup script during O3

export LAL_DATA_PATH=/home/pycbc.live/production/data/
export X509_USER_CERT=/home/pycbc.live/.globus/robot.cert.pem
export X509_USER_KEY=/home/pycbc.live/.globus/robot.key.pem
export OMP_NUM_THREADS=4
export HDF5_USE_FILE_LOCKING="FALSE"

mpirun \
-hostfile /home/pycbc.live/production/O3/mpi_hosts_cit.txt \
-n 150 \
-ppn 1 \
-envlist X509_USER_KEY,X509_USER_CERT,PYTHONPATH,LD_LIBRARY_PATH,OMP_NUM_THREADS,VIRTUAL_ENV,PATH,LAL_DATA_PATH,HDF5_USE_FILE_LOCKING \
\
python -m mpi4py `which pycbc_live` \
--bank-file /home/pycbc.live/production/O3/ER13_H1L1_OPT_FLOW_HYBRID_BANK.hdf \
--sample-rate 2048 \
--enable-bank-start-frequency \
--low-frequency-cutoff 20 \
--max-length 256 \
--approximant "SPAtmplt:mtotal<4" "SEOBNRv4_ROM:else" \
--chisq-bins "0.72*get_freq('fSEOBNRv4Peak',params.mass1,params.mass2,params.spin1z,params.spin2z)**0.7" \
--snr-abort-threshold 500 \
--snr-threshold 4.5 \
--newsnr-threshold 4.5 \
--max-triggers-in-batch 25 \
--store-loudest-index 50 \
--analysis-chunk 8 \
--autogating-threshold 200 \
--highpass-frequency 13 \
--highpass-bandwidth 5 \
--highpass-reduction 200 \
--psd-samples 30 \
--max-psd-abort-distance 600 \
--min-psd-abort-distance 20 \
--psd-abort-difference .15 \
--psd-recalculate-difference .01 \
--psd-inverse-length 3.5 \
--psd-segment-length 4 \
--trim-padding .5 \
--store-psd \
--state-channel H1:GDS-CALIB_STATE_VECTOR L1:GDS-CALIB_STATE_VECTOR V1:DQ_ANALYSIS_STATE_VECTOR \
--channel-name H1:GDS-GATED_STRAIN L1:GDS-GATED_STRAIN V1:Hrec_hoft_16384Hz_Gated \
--data-quality-channel H1:DMT-DQ_VECTOR L1:DMT-DQ_VECTOR V1:DQ_ANALYSIS_STATE_VECTOR \
--data-quality-flags H1:OMC_DCPD_ADC_OVERFLOW,ETMY_ESD_DAC_OVERFLOW L1:OMC_DCPD_ADC_OVERFLOW,ETMY_ESD_DAC_OVERFLOW V1:VIRGO_GOOD_DQ \
--data-quality-padding 1.0 \
--increment-update-cache H1:/dev/shm/kafka/H1 L1:/dev/shm/kafka/L1 V1:/dev/shm/kafka/V1 \
--frame-src H1:/dev/shm/kafka/H1/* L1:/dev/shm/kafka/L1/* V1:/dev/shm/kafka/V1/* \
--processing-scheme cpu:4 \
--fftw-input-float-wisdom-file /home/pycbc.live/production/O3/fftw_wisdom_single_cit \
--fftw-input-double-wisdom-file /home/pycbc.live/production/O3/fftw_wisdom_double_cit \
--fftw-measure-level 0 \
--fftw-threads-backend openmp \
--increment 8 \
--enable-single-detector-background \
--single-newsnr-threshold 10 \
--single-duration-threshold 5 \
--single-fixed-ifar .06 \
--single-reduced-chisq-threshold 2 \
--verbose \
--max-batch-size 16777216 \
--frame-read-timeout 100 \
--output-path /local/pycbc.live/O3/triggers \
--output-status /home/pycbc.live/public_html/production/status.json \
--day-hour-output-prefix \
--background-statistic phasetd_newsnr_sgveto \
--background-statistic-files \
    /home/pycbc.live/production/data/H1L1-PHASE_TIME_AMP_v1.hdf \
    /home/pycbc.live/production/data/H1V1-PHASE_TIME_AMP_TITO.hdf \
    /home/pycbc.live/production/data/L1V1-PHASE_TIME_AMP_TITO.hdf \
--sgchisq-snr-threshold 4 \
--sgchisq-locations "mtotal>40:20-30,20-45,20-60,20-75,20-90,20-105,20-120" \
--enable-background-estimation \
--background-ifar-limit 100 \
--timeslide-interval 0.1 \
--pvalue-combination-livetime 0.0005 \
--ifar-double-followup-threshold 0.0001 \
--ifar-upload-threshold 0.0027 \
--enable-gracedb-upload \
--gracedb-server https://gracedb.ligo.org/api/ \
--enable-production-gracedb-upload \
--round-start-time 4

echo 'The PyCBC Live production analysis has terminated. You may want to check the log messages!' | mail -s 'PyCBC Live terminated' tito.canton@ligo.org sophia.xiao@ligo.org ian.harry@ligo.org bhooshan.gadre@ligo.org khun.phukon@ligo.org
