%% Before selecting ICs %%

clc; clear;
% addpath 'E:\MATLAB_R2021a\eeglab2020_0'; % Add util of eeglab path when first open MATLAB
eeglab;
close all; 

lowfilteredge = 0.1; % Locutoff settings
highfilteredge = 40; % Hicutoff settings
notchfilter = 50; % Notch settings
samplerate = 500; % Set resampling rate

mffpath = 'D:\MATLAB\EEG\Preprocessing\mff\'; % Set original data path
setpath = 'D:\MATLAB\EEG\Preprocessing\set\'; % Set preprocessed data path
csvpath = 'D:\MATLAB\EEG\Preprocessing\csv\'; % Set retained channels & epochs list path (Only for noting)

cd(mffpath);
raw_data = dir('*.mff');
datalist = {raw_data.name};

% Create a var containing retained channels & adjusted recording time after ASR
% procedure, only for noting
if ~exist('BeforeASRinfo','var')
    BeforeASRinfo = {'xtimebegin'};
end
if ~exist('AfterASRinfo','var')
    AfterASRinfo = {'subjname','nbchan','xtime'};
end

for subjnum = 1:length(datalist)
    
    % To recognize whether the imported EEG data is about task or rest 
    try
        % For the task data
        EEG = pop_mffimport({[mffpath datalist{subjnum}]},{'code'});
    catch ME
        if contains(ME.message,'Dot indexing is not supported for variables of this type')
            fprintf(2,['NOTE: ' datalist{subjnum} ' does not contain any markup, indicating that this is EEG resting-state data\n']);
            % For the rest data
            EEG = pop_mffimport({[mffpath datalist{subjnum}]});
        else
            rethrow(ME);
        end
    end

    % Loading dataset if needed
    % EEG = pop_loadset('filename',datalist{subjnum},'filepath',mffpath);

    firstxmax_value = EEG.xmax; oldval = {firstxmax_value};
    BeforeASRinfo = [BeforeASRinfo; oldval];

    % Bandpass and notch filter
    EEG = pop_eegfiltnew(EEG,'locutoff',lowfilteredge,'plotfreqz',0);
    EEG = pop_eegfiltnew(EEG,'hicutoff',highfilteredge,'plotfreqz',0);
    EEG = pop_eegfiltnew(EEG,'locutoff',notchfilter-2,'hicutoff',notchfilter+2,'revfilt',1,'plotfreqz',0);
    
    % Changing resampling rate
    EEG = pop_resample(EEG,samplerate);
    
    % Both bad channels and time windows removal according to Clean Rawdata and ASR (Default settings)
    EEG = pop_clean_rawdata(EEG,'FlatlineCriterion',5,...
    'ChannelCriterion',0.8,'LineNoiseCriterion',4,...
    'Highpass','off','BurstCriterion',20,...
    'WindowCriterion',0.25,'BurstRejection','on',...
    'Distance','Euclidian','WindowCriterionTolerances',[-Inf 7]);
    
    % Only bad channels and basic windows removal according to Clean Rawdata and ASR
    % EEG = pop_clean_rawdata(EEG,'FlatlineCriterion',5,...
    % 'ChannelCriterion',0.8,'LineNoiseCriterion',4,...
    % 'Highpass','off','BurstCriterion',20,...
    % 'WindowCriterion','off','BurstRejection','on',...
    % 'Distance','Euclidian');

    % More conservative cleaning way according to Clean Rawdata and ASR
    % EEG = pop_clean_rawdata(EEG,'FlatlineCriterion',5,...
    % 'ChannelCriterion',0.85,'LineNoiseCriterion',4,...
    %'Highpass','off','BurstCriterion',20,...
    % 'WindowCriterion',0.3,'BurstRejection','off',...
    % 'Distance','Euclidian','WindowCriterionTolerances',[-Inf 7],...
    % 'ChannelCriterionMaxBadTime',0.5,...
    % 'BurstCriterionRefMaxBadChns',0.2,...
    % 'BurstCriterionRefTolerances',[-Inf 5.5]);

    % Listing retained channels & adjusted recording time after ASR (Only for noting)
    setname_value = EEG.setname; nbchan_value = EEG.nbchan; xmax_value = EEG.xmax;
    Latestval = {setname_value,nbchan_value,xmax_value};
    AfterASRinfo = [AfterASRinfo; Latestval];    
    if subjnum == length(datalist)
        BeforeASRinfo_table = cell2table(BeforeASRinfo(2:end,:),'VariableNames',BeforeASRinfo(1,:));
        AfterASRinfo_table = cell2table(AfterASRinfo(2:end,:),'VariableNames',AfterASRinfo(1,:));
        MergeASRinfo_table = [AfterASRinfo_table,BeforeASRinfo_table];
        writetable(MergeASRinfo_table,[csvpath 'AfterASRinfo_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.csv']);
    end
    
    % Computing average reference
    EEG = pop_reref(EEG,[]);

    % Performing ICA analysis
    EEG = pop_runica(EEG,'icatype','runica','extended',1,'pca',64,'interrupt','on');
    EEG = eeg_checkset(EEG);
 
    % Eventually save dataset
    EEG = pop_saveset(EEG,'filename',[datalist{subjnum}(1:end-4) '_ICAed.set'],'filepath',setpath);
    close all;
    
end

%% Removing bad channels inspected by eyes (Manually evaluate if needed)

% Enter the channel you want to remove
% EEG = pop_select(EEG,'nochannel',{'E1','E2'});

%% Selecting ICs manually for each subject with the help of IClabel (Manually evaluate if needed)

% EEG = pop_icflag(EEG,[NaN NaN;0.8 1;0.8 1;0.8 1;0.8 1;0.8 1;NaN NaN]);
% EEG = pop_subcomp(EEG,[],0); % Input artifact ICs in []
% pop_eegplot(EEG,1,1,1); % Eventually check the data

%% Interpolating bad channels for each subject (Manually evaluate)

% For full selected 129 or 257 channels
% load('D:\MATLAB\EEG\Preprocessing\full_selected_channels.mat');
% load('D:\MATLAB\EEG\Preprocessing\full_selected_channels_129.mat');

% Interpolating bad channels with 129 or 257 sizes
% EEG = pop_interp(EEG,full_selected_channels,'spherical'); EEG = eeg_checkset(EEG);
% EEG = pop_interp(EEG,full_selected_channels_129,'spherical'); EEG = eeg_checkset(EEG);
