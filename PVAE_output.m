pt=pks_tb.parent;
count=0;
for i=1:length(pt)
    if ~isempty(pt{i})
        count=count+1;
        pt{i}.scoremat=[];
       %struct2table(parent{i})
       parent(i,1)=pt{i}.mz;
       parent(i,2)=pt{i}.rt;
       parent(i,3)=pt{i}.sig;
       parent(i,4)=pt{i}.N_num;
       parent(i,5)=pt{i}.C_num;
       parent(i,6)=pt{i}.score;       
    else
       parent(i,1:6)=[0 0 0 0 0 0]; 
    end
end
parent_tb=array2table(parent);
pks_tb=struct2table(pks);
pks_tb.scoremat=[];
pks_tb=[pks_tb,parent_tb];
writetable(pks_tb,'pks_neg.xlsx')