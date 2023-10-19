# Multilayer network associations between the exposome and childhood brain development

Code available in the repository: structural and functional MRI preprocessing, network construction (including residualization of brain measures), and sum score analysis

## Preprocessing

Code assumes that structural images have been processed using Freesurfers _recon_all_ for structural images. Morphometric data by parcel is extracted using the getParcelsSchaefer.sh script in the [preproc](/preproc/) directory. For functional images, preprocessing scripts are available in this repository [here](/preproc/), with [MRIQC](/preproc/mriqc) for QC measures and [fMRIPrep](/preproc/fmriprep) and [xcpEngine](/preproc/xcpEngine) for processing.

## Main analyses

The main analyses were done using the main script ["bilayer_network_analyses.rmd"](bilayer_network_analyses.rmd) available in the main directory - this code reads in the preprocessed and extracted structural and functional data as well as the exposome data, residualizes brain measures, estimates networks and performs all analyses detailed in the main manuscript.  Exposome data preparation is excluded from this repo, given the sensitivity of handling location data.

## Supplemental analyses

Sum score analyses are available (here)[sum_score_analysis.rmd]

Other supplemental analyses such as t-tests between excluded and included groups (Supplemental Tables 1 and 2 in the manuscript), age-brain measure correlations (Supplemental Figure 1), and partial correlation network coefficient matrices (Supplemental Figures 2 and 3) are available in same RMarkdown file as the main analyses - [here](bilayer_network_analyses.rmd)
