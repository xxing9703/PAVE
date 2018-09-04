clear
%********************************initialize settings
settings.mode=-1;   % neg -1, pos 1
settings.rtm=0.3;    %rt resolution
settings.ppm=10/1e6;  %mass resolution
settings.rt_tol=0.1;  %rt tolerance
settings.mz_tol=10/1e6; %mz tolerance
settings.ave=5;    % used in EIC.m
settings.prominence=1e3; % used in EIC.m
settings.peakwidth=0.02; % used in EIC.m
settings.scorecutoff=0.75; % Correlation Score cutoff, below which is considered background
settings.threshold=0.75; % Correlation score threshold for pattern recognition
settings.override=0; % id fixed if pk.feature is filled (=0). id can change (=1) 
settings.verbose=1; % display the progress
rep=[3 3 3 3 2]; %repeated runs for [unlabel, 15N, 13C, 13C15N, pblk]
addpath('..\');
%********************************Loading 
pathname=''; %+++ pathname
load (fullfile(pathname,'M_neg_yeast.mat')) %+++++++ load raw data, M
pks=readtable(fullfile(pathname,'Peaklist-yeast-neg.csv')); %+++++++ load peaklist generated from el-maven
    pks=pks(:,[3,5,6]);
    pks.Properties.VariableNames={'id','mz','rt'};
    pks=table2struct(pks);

%setup adduct list and configurations
adduct=readtable(fullfile(pathname,'adduct_list_config.xlsx')); %+++++++ load adduct table
    adduct=table2struct(adduct);

load(fullfile(pathname,'boundary99')); %++++ for Low C compound

load(fullfile(pathname,'M_CID_neg_yeast.mat'))%+++++++ load raw CID data, M_CID
list=readtable(fullfile(pathname,'CID-neg-yeast.csv')); %+++++++ CID peaklist generated from el-maven
    list=list(:,[5,6]);
    list=table2array(list);
dbase=readtable(fullfile(pathname,'db_master.xlsx'));%+++++++ load dbase

% --------run PAVE

PAVE_main

