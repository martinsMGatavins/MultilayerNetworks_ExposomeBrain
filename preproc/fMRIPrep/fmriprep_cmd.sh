#$ -j y
#$ -l h_vmem=25.1G,s_vmem=25G
#$ -o /cbica/projects/cbpd_main_data/qsub_output

CBICA_HOME=/cbica
MACKEY_HOME=/cbica/projects/cbpd_main_data
BIDS_folder=projects/cbpd_main_data/CBPD_bids_crosssectional
subject=${1}
tools_dir=${MACKEY_HOME}/tools/singularity
output_dir=${BIDS_folder}/derivatives/

unset PYTHONPATH;
echo 'job is running'
singularity run --cleanenv -B ${CBICA_HOME}:/mnt ${tools_dir}/fmriprep-1.2.6-1.simg \
/mnt/${BIDS_folder} /mnt/${BIDS_folder}/derivatives \
participant \
-w  /mnt/home/gatavinm/fmriprep_wd \
--participant-label ${subject} \
--fs-license-file $HOME/license.txt \
--output-space T1w template \
--ignore fieldmaps sbref \
--nthreads 1 \
--skip-bids-validation \
