function [pks,idx]=pave_dbsearch(dbase,pks,settings)

H=1.0078;
name=table2array(dbase(:,2));
formula=table2array(dbase(:,3));

db=table2array(dbase(:,4:6));
id=find(db(:,1)<=max([pks.mz])+2);
db=db(id,:);
ppm=settings.ppm;
assign=[];
idx=[];count=0;


for i=1:length(pks)
  mz=pks(i).mz-settings.mode*H;
  C_num=pks(i).C_num;
  N_num=pks(i).N_num;
  assign{i,1}='';
  assign{i,2}='';
  assign{i,3}='';
  assign{i,4}='';
  for j=1:size(db,1)
      rppm=abs(mz-db(j,1))/mz;
      if rppm<ppm && isempty(assign{i,4})
            assign{i,1}=formula{j}; 
            assign{i,2}=db(j,3); 
            assign{i,3}=db(j,2); 
         if C_num==db(j,2)&& N_num==db(j,3)% C N match
            assign{i,4}='confirmed';            
            count=count+1;
            
            if isempty(pks(i).feature)||settings.override==1
               pks(i).feature='Metabolite';
               pks(i).formula=formula{j};
               idx=[idx,i];
            end
            
         end
      
      end
  end
  if settings.verbose==1
     fprintf(['dbsearch:',num2str(length(idx)),'/',num2str(count),'/',num2str(i),'\n']);
  
  end
end
