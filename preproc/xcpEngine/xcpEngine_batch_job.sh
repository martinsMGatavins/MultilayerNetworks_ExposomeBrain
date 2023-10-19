#!/bin/bash
MACKEY_HOME=/cbica/projects/cbpd_main_data
temp_dir=/cbica/home/gatavinm/xcpEngine_wd
projdir=${MACKEY_HOME}/dropbox/resting_state_replication
tools_dir=${MACKEY_HOME}/tools/singularity
FULL_COHORT=${projdir}/xcpEngine/n5_xcpPriorityList.csv
NJOBS=8 #number of scans in the FULL_COHORT file

cat << EOF > xcpParallel.sh
#$ -j y
#$ -l h_vmem=95.1G,s_vmem=95.0G
#$ -o /cbica/projects/cbpd_main_data/qsub_output
#$ -t 1-${NJOBS}

# Adjust these so they work on your system
SNGL=/usr/bin/singularity
SIMG=${tools_dir}/xcpEngine-100219.simg
FULL_COHORT=${FULL_COHORT}

# Create a temp cohort file with 1 line
HEADER=\$(head -n 1 \$FULL_COHORT)
LINE_NUM=\$( expr \$SGE_TASK_ID + 1 )
LINE=\$(awk "NR==\$LINE_NUM" \$FULL_COHORT)
TEMP_COHORT=\${FULL_COHORT}.\${SGE_TASK_ID}.csv
echo \$HEADER > \$TEMP_COHORT
echo \$LINE >> \$TEMP_COHORT

echo 'temporary directory is ' \$TMPDIR
\$SNGL run --cleanenv --env R_PROFILE_USER=usr,R_ENVIRON_USER=usr -B \$TMPDIR:/tmp \$SIMG \\
  -c \${TEMP_COHORT} \\
  -d ${projdir}/xcpEngine/fc-36p-gsr-meancsfwm-spkreg-fd0.5-dv1.75-dropvols.dsn \\
  -o ${MACKEY_HOME}/CBPD_bids_crosssectional/derivatives/xcpEngine_gsr_spkreg_fd0.5dvars1.75_drpvls \\
  -i ${MACKEY_HOME}/CBPD_bids_crosssectional/derivatives/xcpengine_wd_2 \\
  -t 2

EOF

qsub xcpParallel.sh
