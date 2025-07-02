# EEG-EGI-Preprocessing
A MATLAB-based multi-subjects preprocessing pipeline in batch for EEG data (specifically tested on 129/257 channels EGI system [.mff format]), including a two-stage (Pre-ICA + Post-ICA) step.

With several custom adjustments, it should be suited for other electrophysiological measurement systems as well.

The codes above require EEGLAB (under test at version v2021.1), and its plugin 'MFFMatlabIO', 'clean_rawdata', 'ERPLAB'.

The file 'group_pre_beforeICA' (group_pre_beforeICA.m) configures some parameters and path settings. This code includes five steps:

1) Resampling
2) Bandpass and notch filtering
3) Automatic timepoints/channels rejection marking (with retention list output saving as .csv)
4) Re-referencing (average by default)
5) ICA decomposition

Between the pre-ICA steps and post-ICA steps, users should review & choose artifact ICs manually, and conduct bad channels interpolation according to manually-evaluated code.

The file 'group_pre_postICA_ERPLAB' (group_postICA_ERPLAB.m) also configures some parameters and path settings. This code includes six steps:

1) Bin detection
2) Creating eventlist & Assign Bin
3) Extracting bin-based epochs
4) Final artifact removal based on ERPLAB
5) Computing averaged ERPs
6) Plotting multi-channel topo

The pipeline generates EEGLAB-compatible .fdt and .set files after both preprocessing stages (pre-ICA and post-ICA), preserving all metadata and processed data for subsequent analysis.

Please note that there is no unique, correct way of preprocessing EEG data. This pipeline represents one approach to EEG preprocessing. Always validate with your specific experimental design and data characteristics.

For questions or contributions, please open an issue or submit a pull request :-)!
