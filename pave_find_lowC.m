%determine is a pk with given C number and mz is reasonable. if not,
%annotate as low_C(high mz). Requires input of the boundary mz
function [pks,count]=pave_find_lowC(pks,settings,m)
count=0;idx=[];
for i=1:length(pks)
mz=pks(i).mz;
C_num=pks(i).C_num;
  
if C_num>0 && mz>m(C_num)
    if isempty(pks(i).feature)||settings.override==1
        pks(i).feature='Low_C';
        count=count+1;
        idx=[idx,i];
    end
    
end

    if settings.verbose==1
          fprintf(['find_Low_C:',num2str(count),'/',num2str(i),'\n']);
    end
end