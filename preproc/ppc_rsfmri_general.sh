CBPDMAINDATA=/cbica/projects/cbpd_main_data
work_dir=${CBPDMAINDATA}/dropbox/resting_state_replication
subject_list=${work_dir}/n59_cbpd_nwbd_cleared_for_processing.txt
BIDS_dir=${CBPDMAINDATA}/CBPD_bids
output_dir=${CBPDMAINDATA}/CBPD_bids_crosssectional

for sub in `cat ${subject_list}`
do
  echo ${sub}
  newsub=`echo ${sub} | tr -d _`
if [[ -d ${output_dir}/sub-${newsub} ]]; then
  echo it exists
else
  if [[ ${sub} == *_2 ]]; then
     echo 'its longitudinal T2'
     echo $newsub
     cp -r ${BIDS_dir}/sub-${sub:0:8}/ses-02/. ${output_dir}/sub-${newsub}/
  elif [[ ${sub} == *_3 ]]; then
     echo 'its longitudinal T3'
     echo $newsub
     cp -r ${BIDS_dir}/sub-${sub:0:8}/ses-03/. ${output_dir}/sub-${newsub}/
  else
     echo 'its not longitudinal'
     cp -r ${BIDS_dir}/sub-${sub:0:8}/ses-01/. ${output_dir}/sub-${newsub}/
  fi
fi
done

cd ${output_dir}
#taking out unnecessary ses-xx in filenames that is breaking BIDS validation, run on CBPD_bids
#CBPD files - ses-01
find ${output_dir} -not -path "${output_dir}/derivatives*" -type f -name 'sub-CBPD*_ses-01_*' | while read FILE; do
  echo "${FILE}"
  newfile="$(echo ${FILE} | sed -e 's|_ses-01||')" ;
  echo "${newfile}"
  mv "${FILE}" "${newfile}" ;
done

# NWBD files
find ${output_dir} -not -path "${output_dir}/derivatives*" -type f -name 'sub-NWBD*_ses-01_*' | while read FILE; do
  echo "${FILE}"
  newfile="$(echo ${FILE} | sed -e 's|_ses-01||')" ;
  echo "${newfile}"
  mv "${FILE}" "${newfile}" ;
done

#CBPD files - ses-02/03
find . -not -path "./derivatives*" -type f -name 'sub-CBPD*_ses-02_*' | while read FILE; do
  echo "${FILE}"
  #add a 2 onto subject name, remove ses-02
  newfile="$(echo ${FILE} | sed -e 's|_ses-02||' | sed -e 's|[a-z0-9]/sub-CBPD....|&2|')" ;
  echo "${newfile}"
  mv "${FILE}" "${newfile}"
done

find . -not -path "./derivatives*" -type f -name 'sub-CBPD*_ses-03_*' | while read FILE; do
  echo "${FILE}"
  #add a 2 onto subject name, remove ses-02
  newfile="$(echo ${FILE} | sed -e 's|_ses-03||' | sed -e 's|[a-z0-9]/sub-CBPD....|&3|')" ;
  echo "${newfile}"
  mv "${FILE}" "${newfile}"
done
cd ${work_dir}

#copy freesurfer recon output from main BIDS directory
for sub in `cat ${subject_list}`
do
  echo ${sub}
  newsub=`echo ${sub} | tr -d _`
  export SUBJECTS_DIR=${output_dir}/derivatives/freesurfer
if [ -d ${SUBJECTS_DIR}/sub-${newsub} ]; then
    echo 'Freesurfer is already run for' ${sub}
else
    echo 'Freesurfer not in directory for' ${sub}
  if [[ ${sub} == *_2 ]]; then
     echo 'its longitudinal T2'
     echo $newsub
     cp -r ${BIDS_dir}/derivatives/freesurfer_t2/sub-${sub:0:8}/. ${SUBJECTS_DIR}/sub-${newsub}/
  elif [[ ${sub} == *_3 ]]; then
     echo 'its longitudinal T3'
     echo $newsub
     cp -r ${BIDS_dir}/derivatives/freesurfer_t3/sub-${sub:0:8}/.  ${SUBJECTS_DIR}/sub-${newsub}/
  else
    echo 'its not longitudinal'
    if [[ ${sub} == NWBD* ]]; then
      echo 'its an NWBD file'
      cp -r ${BIDS_dir}/derivatives/freesurfer_t1/${sub}/.  ${SUBJECTS_DIR}/sub-${newsub}/
    else
      echo 'its a CBPD file'
      cp -r ${BIDS_dir}/derivatives/freesurfer_t1/sub-${sub}/.  ${SUBJECTS_DIR}/sub-${newsub}/
    fi
  fi
fi
done

#run MRIQC and fMRIprep
#xcpEngine is on a separate script
for sub in `cat ${subject_list}`
do
  echo ${sub}
  newsub=`echo ${sub} | tr -d _`
  echo ${newsub}
#if [ -e ${output_dir}/derivatives/mriqc_fd_2_mm/sub-${newsub}_run-01_T1w.html ]; then
#  echo 'MRIQC already run for' ${sub}
#else
  echo 'Submitting MRIQC job for' ${sub}
  qsub -j y ${work_dir}/mriqc/mriqc_cmd.sh ${newsub}
#fi

#if [[ -e ${output_dir}/derivatives/fmriprep/sub-${newsub}/func/sub-${newsub}_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz ]]; then
#  echo 'fmriprep exists for' ${sub}
  #check if xcpEngine is already run for this pipeline and this person.
  # last_run=$(find ${BIDS_dir}/sub-${newsub}/func/ -name "*task-rest_run-*" -type f| cut -d- -f5 | cut -d_ -f1 |sort -n | tail -n1)
  # last_run=${last_run:1}
  # echo $last_run
  # for run in $(seq 1 $last_run); #loop through the runs
  # do
  #   if [[ -e ${output_dir}/derivatives/xcpEngine_nogsr_spkreg_fd0.5dvars1.75_drpvls/sub-${newsub}/run-0${run}/regress/sub-${newsub}_run-0${run}_residualised.nii.gz ]]; then
  #     echo 'Xcpengine run already for run' ${run} 'sub' ${sub}
  #   fi
  #     #echo rm ${output_dir}/derivatives/xcpEngine_nogsr_spkreg_fd0.5dvars1.75_drpvls/sub-${newsub}/run-0${run}/ -R
  #     # echo 'Put run' ${run} 'in list for xcpEngine for' ${sub}
  #     # find ${BIDS_dir} -type f | grep "${newsub}_task-rest_run-0${run}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz\$"| while read fname; do
  #     # tmp=$(echo "$fname" | awk -F '_' '{print $5}' ) #this parses on underscores and pulls 'run-01'
  #     # fname_mnt=$(echo "$fname" | sed -e 's|/data/|/mnt/|' )
  #     # echo sub-${newsub},${tmp},${fname_mnt} >> ${subject_list_dir}/nxxx_cleanup_for_xcpEngine.csv
  #     #fi
  # done
#else
  echo 'No fMRIprep - run fMRIPrep for' ${sub}
  qsub -j y ${work_dir}/fmriprep/fmriprep_cmd.sh sub-${newsub}
#fi
done
