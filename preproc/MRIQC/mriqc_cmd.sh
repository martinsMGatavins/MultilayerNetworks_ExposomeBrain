#!/bin/sh
#$ -j y
#$ -l h_vmem=20.1G,s_vmem=20G
#$ -o /cbica/projects/cbpd_main_data/qsub_output

module load python
conda create -n mriqc_env python=3.6
source activate mriqc_env
conda config --append channels conda-forge
conda install python-dateutil dcm2niix pandas
conda install -c conda-forge jq
pip install --user pybids==0.6.5 jinja2
pip install --user numpy==1.14 nibabel

CBICA_HOME=/cbica
MACKEY_HOME=${CBICA_HOME}/projects/cbpd_main_data
BIDS_folder=projects/cbpd_main_data/CBPD_bids_crosssectional
subject=${1}
tools_dir=${MACKEY_HOME}/tools/singularity
output_dir=${BIDS_folder}/derivatives/mriqc_fd_2_mm
echo $subject
echo $BIDS_folder

#unset PYTHONPATH;
singularity run --cleanenv -B ${CBICA_HOME}:/mnt ${tools_dir}/mriqc-0.14.2.simg \
/mnt/${BIDS_folder} /mnt/${output_dir} \
participant \
-w /mnt/home/gatavinm/mriqc_wd \
--participant_label ${subject} \
--fd_thres 2 \
--no-sub \
--n_procs 10 \
