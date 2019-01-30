#!/bin/bash                                                                                                                                                                                                                                      

n=${1}
LIGO_USERNAME=${2}

if test x${LIGO_USERNAME} == "x" ; then
  echo "Error: user name not given."
  echo
  echo "Usage: ${0} ANALYSIS albert.einstein"
  echo
  echo "where albert.einstein is your LIGO.ORG username."
  exit 1
fi

PROJECT_PATH=/home/$USER/cbc/O2/clean_data_runs_production_v5/cit/
WEB_PATH=/home/$USER/public_html/LSC/O2/clean_data_runs/
GITHUB_TAG="v1.11.14"
CONFIG_TAG="v1.11.7"
GITHUB_URL="https://git.ligo.org/ligo-cbc/pycbc-config/${GITHUB_TAG}/O2clean/pipeline"
CONFIG_URL="https://git.ligo.org/ligo-cbc/pycbc-config/raw/${CONFIG_TAG}/O2clean/pipeline"
#Use PyCBC v1.9.1 frokm cvmfs

set -e

source /cvmfs/oasis.opensciencegrid.org/ligo/sw/pycbc/x86_64_rhel_7/virtualenv/pycbc-${GITHUB_TAG}/bin/activate

ligo-proxy-init -p $LIGO_USERNAME
ecp-cookie-init LIGO.ORG https://git.ligo.org/users/auth/shibboleth/callback $LIGO_USERNAME

WORKFLOW_NAME=o2-c02-clean-analysis-rerun6060-${n}-${GITHUB_TAG}
OUTPUT_PATH=${WEB_PATH}/${WORKFLOW_NAME}
WORKFLOW_TITLE="'O2 Analysis ${n} with Cleaned C02 Data'"
WORKFLOW_SUBTITLE="'PyCBC, PyCBC-config ${CONFIG_TAG}'"

if [ -d ${PROJECT_PATH}/$WORKFLOW_NAME ] ; then
  echo "${PROJECT_PATH}/$WORKFLOW_NAME already exists"
  echo "Do you want to remove this directory or skip to the next block? Type remove or skip"
  read RESPONSE
  if test x$RESPONSE == xremove ; then
    echo "Are you sure you want to remove ${WORKFLOW_NAME}?"
    echo "Type remove to delete ${PROJECT_PATH}/$WORKFLOW_NAME or anything else to exit"
    read REMOVE
    if test x$REMOVE == xremove ; then
      rm -rf ${PROJECT_PATH}/$WORKFLOW_NAME
    else
      echo "You did not type remove. Exiting"
      exit 1
    fi
  elif test x$RESPONSE == xskip ; then
    continue
  else
    echo "Error: unknown response $RESPONSE"
    exit 1
  fi
fi
mkdir -p ${PROJECT_PATH}/$WORKFLOW_NAME
pushd ${PROJECT_PATH}/$WORKFLOW_NAME

pycbc_make_coinc_search_workflow \
--workflow-name ${WORKFLOW_NAME} --output-dir output \
--config-files \
  ${CONFIG_URL}/analysis.ini \
  ${CONFIG_URL}/data_C02.ini \
  ${CONFIG_URL}/executables.ini \
  ${CONFIG_URL}/nrinjections_rerun6060.ini \
  ${CONFIG_URL}/plotting.ini \
  ${CONFIG_URL}/gating.ini \
  ${CONFIG_URL}/gps_times_O2_analysis_${n}.ini \
--config-overrides \
  "results_page:output-path:${OUTPUT_PATH}" \
  "results_page:analysis-title:${WORKFLOW_TITLE}" \
  "results_page:analysis-subtitle:${WORKFLOW_SUBTITLE}" \
  "workflow:file-retention-level:merged_triggers" \
  #"pegasus-profile:condor|request_memory: ifthenelse( (LastHoldReasonCode=!=34 && LastHoldReasonCode=!=0), InitialRequestMemory, int(1.5 * NumJobStarts * MemoryUsage) )"
  #"pegasus_profile:condor|request_disk: 200000" \
pushd output

pycbc_submit_dax \
  --local-dir /local/$USER/ \
  --accounting-group ligo.prod.o2.cbc.bbh.pycbcoffline \
  --dax ${WORKFLOW_NAME}.dax \
  --cache-file /home/juancalderonbustillo/Atlas/cbc/O2/clean_data/production_runs/reuse_caches/local_cit_reused_files_analysis-$n.map \

popd
popd


