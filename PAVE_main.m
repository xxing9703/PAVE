% list of required files in the same folder:
% 1) M file parsed from mzXML, must be in the correct ordering (un, N, C, NC, blk)
% 2) peak list - for unlabeled  (El-maven generated)
% 3) adduct list with configuations
% 4) peak list - for CID only (El-mave generated)
% 5) M file parsed from mzXML, for CID only, must be in the correct ordering (0eV, 2eV, 4eV)
% 6) dbase for formula assignment.
% 7) boundry of m/z vs C count for determining Low_C compounds.


%% initialize setting parameters,load M and peaklist, load adduct config.
%PAVE_ini  

%% -- remove duplicates, defined by tolerance in settings
pks = pave_find_dup(pks,settings);
pks = pave_atomcount(M,pks,settings,rep); %atomcount sp01 
pks = pave_junkremover(M,pks,settings,rep,adduct); %junkremover sp02
pks = pave_find_lowC(pks,settings,m);% - annotation of Low_C  sp03

pks = pave_identify_frag(M_CID,list,pks,settings); %CID fragment sp04
pks = pave_dbsearch(dbase,pks,settings); % -- dbsearch sp05

%% PAVE2
% pks = pave2_find_artifact(pks,settings);%remove artifacts of peak ring
% 
% 
% 
% pks_tb=struct2table(pks);
% PAVE_stat

%writetable(pks_tb(:,1:11),'pks_neg.xlsx') %export to excel file

%% get the counts of your named category
% ft='Artifacts';
% size(find(strcmp({pks.feature},ft)),2)  %counting