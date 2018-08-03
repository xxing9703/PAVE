function [pks,idx]=pave_junkremover(M,pks,settings,rep,adduct)
idx=[];
for i=1:length(adduct)
  [pks,id,~] = pave_find_adduct(M,pks,settings,rep,adduct(i)); % -junkremover
  idx=[idx,id];
end

[pks,id,~]=pave_find_dimer(M,pks,settings,rep);
idx=[idx,id];

