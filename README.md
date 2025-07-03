# EEG-EGI-Preprocessing
This is a MATLAB-based preprocessing pipeline in multi-subject batch for EEG data, which was specifically tested on 129/257 channels in EGI system (named .mff format). With several custom adjustments and add-on files, it should be suitable for other electrophysiological measurement systems (e.g., Neuroscan, BrainProduct, or BEL, etc.) as well.

The preprocessing pipeline consists of a two-stage (Pre-ICA + Post-ICA) procedure, while selecting potential artifact ICs manually is necessary.

The codes here require EEGLAB (under test at version v2021.1, but earlier versions also should run smoothly), which includes sub-plugins 'MFFMatlabIO', 'clean_rawdata', and 'ERPLAB'.

For the first step, the 'group_pre_beforeICA.m' configures some parameters and path settings. This code includes five basic steps:

1) Resampling
2) Bandpass and notch filtering
3) Automatic timepoints / channels rejection marking (with retention list output saving as .csv)
4) Re-referencing (average by all channels by default)
5) ICA decomposition

For the second step, the 'group_pre_postICA_ERPLAB.m' also configures parameters and path settings based on the user's needs (i.e., to obtain standardized, cleaned, and epoched ERP data). This code includes six steps binding with ERPLAB plugins:

1) Bin detection
2) Creating eventlist & Assign Bin
3) Extracting bin-based epochs
4) Final artifact removal based on ERPLAB
5) Computing averaged ERPs
6) Plotting multi-channel topos
   
Notably, between the pre-ICA and post-ICA procedure, users should review & choose artifact ICs manually, and conduct bad channels interpolation according to the manually-evaluated code based on the custom file about channel location.

The pipeline will generate EEGLAB-compatible .fdt / .set format after each preprocessing stage, preserving all metadata and processed (named '_done.set' by default) data for subsequent analysis.

It should be clear that there is no unique, correct way of preprocessing EEG data. This pipeline only represents one approach to EEG preprocessing according to the author's 5-year experience. Furthermore, users should always validate with specific experimental designs and data characteristics.

For questions or contributions, pls contact h2583911160@gmail.com for questions and remarks :-)!
