%% After selecting and removing Artifact ICs and save data as '_pruned.set' %%

clc; clear;
% addpath E:\MATLAB\toolbox\eeglab2021.1 % Add util of eeglab path when first open MATLAB
eeglab;
close all;

samplerate = 500; % Set sampling rate
epochband = [-100,600]; % Set ERP epoch timeband (ms)
bslband = [-100 0]; % Set ERP baseline timeband (ms)
bintype = 'BIN.txt'; % Set the type of bin according to experiment (Upon ERPLAB request)

curpath = cd;
donepath = '\done\'; setpath = '\set\'; evlistpath = '\eventlist\'; erppath = '\erp\'; binpath = '\bin\'; figpath = '\fig\';

cd([curpath setpath]);
raw_data = dir('*.set');
datalist = {raw_data.name};

%% Detection of assigned bin %%

NobinfoundDatalist = {};
Nobinfound = false;

for subjnum_test4bin = 1:length(datalist)
    EEG = pop_loadset('filename',datalist{subjnum_test4bin},'filepath',[curpath,setpath]);
    EEG = eeg_checkset(EEG);
    if ~any(contains({EEG.event.code},'1111')) % Code details based on your needs
    NobinfoundDatalist{end+1} = EEG.filename;
    Nobinfound = true;
    end
end

if ~isempty(NobinfoundDatalist)
    fprintf(2,'Datalist of unassigned bin:\n');
    disp(NobinfoundDatalist);
    return;
else
    fprintf(2,'All bins were detected so that the following steps would continue...\n')
end

%% ERPLAB preprocessing details %%

if ~Nobinfound
    for subjnum = 1:length(datalist)
        EEG = pop_loadset('filename',datalist{subjnum},'filepath',[curpath,setpath]);
        EEG = eeg_checkset(EEG);    
    
        % Create eventlist
        EventListName = [curpath,evlistpath,datalist{subjnum}(1:end-17),'.txt']; % change to (1:end-4) if your dataname format are 'NAME.set', (1:end-17) if your dataname format are 'NAME_testX_pruned.set'
        EEG = pop_creabasiceventlist(EEG,'AlphanumericCleaning','on','BoundaryNumeric',{-99},'BoundaryString',{'boundary'},'Eventlist',EventListName);
        
        % Assign bin & Extract bin-based epochs
        EEG = pop_binlister(EEG,'BDF',[curpath,binpath,bintype],'ImportEL',EventListName,'IndexEL',1,'SendEL2','EEG','Voutput','EEG'); 
        EEG = pop_epochbin(EEG,epochband,bslband); 
        
        % Artifact detection and removal in ERPLAB system
        EEG = pop_artmwppth(EEG,'Channel',1:EEG.nbchan,'Flag',1,'Threshold',100,...
        'Twindow',[epochband(1),epochband(end)-1000/samplerate],'Windowsize',200,'Windowstep',100);
        EEG = eeg_checkset(EEG);
        
        % Compute averaged ERPs
        ERP = pop_averager(EEG,'Criterion','good','DQ_flag',1,'ExcludeBoundary','on','SEM','on');
        erpname = datalist{subjnum}(1:end-16); % change to (1:end-4) if your dataname format are 'NAME.set', (1:end-17) if your dataname format are 'NAME_testX_pruned.set'
        erpfilename = [datalist{subjnum}(1:end-16),'.erp']; % change to (1:end-4) if your dataname format are 'NAME.set', (1:end-17) if your dataname format are 'NAME_testX_pruned.set'
        ERP = pop_savemyerp(ERP, 'erpname',erpname,'filename',erpfilename,'filepath',[curpath,erppath],'Warning','on');
        
        % Eventually save done data
        savename = [datalist{subjnum}(1:end-16),'_','_done.set']; % change to (1:end-4) if your dataname format are 'NAME.set', (1:end-17) if your dataname format are 'NAME_testX_pruned.set'
        EEG = pop_saveset(EEG,'filename',savename,'filepath',[curpath,donepath]);
        EEG = eeg_checkset(EEG);
        
        % Plot multichannels topos
        Fig = figure; pop_plottopo(EEG,1:EEG.nbchan,erpname,0,'ydir',1);
        saveas(Fig,[curpath,figpath,erpname,'.fig'],'fig');
        saveas(Fig,[curpath,figpath,erpname,'.tiff'],'tiff'); % Store
        close all;
    end
end
