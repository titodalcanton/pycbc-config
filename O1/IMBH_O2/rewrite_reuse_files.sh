#!/bin/bash

for f in {1..9}
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name


   cat ./reuse_files_original/reused_files_analysis-$f.map | grep "hdfs" | sed 's/pool="osg"/pool="local"/g' | sed 's#gsiftp://ldas-osg.ligo.caltech.edu#file://#g' > ./reuse_caches/local_cit_reused_files_analysis-$f.map


#  /home/juan.bustillo/pycbc-dev/bin/pycbc_page_sensitivity  --dist-bins 50 --integration-method pylal --bin-type mchirp --bins 17.9 261.2  --sig-type ifar --sig-bins 0.1 1 10 100 1000 8912 --injection-file $f  --output-file H1L1-PLOT_SENSITIVITY_SUB_MCHIRP_STAT_EOB1INJ_INJ-1126051217-3331800.png
  #echo $f
done




