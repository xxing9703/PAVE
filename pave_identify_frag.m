function [pks,idx]=pave_identify_frag(M_CID,list,pks,settings)
%--------------------------

%--------------------------- 
%load CID raw data 
%load CID peak list for rt calibration, 

%list=xlsread('CID-neg-yeast.csv');
%list=list(:,4:5); 
fprintf('id_fragment...')
count=0;
frag=0;
idx=[];

for i=1:length(pks)
   if isempty(pks(i).feature) || settings.override==1 %pks(i).C_num>0
    [sig,out,rt_fix(i)]=isfrag_fix(M_CID,list,pks(i),settings);
    if min(sig)>0
        count=count+1;
    end
    if max(out)>1
     frag=frag+1;
     idx=[idx,i];
     
     pks(i).fragment=max(out);
     if isempty(pks(i).feature)
          pks(i).feature='Fragment';
     end
     
    else
     pks(i).fragment=0;
    end
    
    if settings.verbose==1
          fprintf(['CID_frag:',num2str(frag),'/',num2str(i),'\n']);
    end
    
    
   else
    pks(i).fragment=0;
   end
end
fprintf('Done\n')
end



function [sig,out,rt_fix]=isfrag_fix(M,list,pk,settings)
 ppm=settings.ppm; rtm=settings.rtm;
 mz=pk.mz; rt=pk.rt;
 ind=find(list(:,1)>mz*(1-ppm));
 list=list(ind,:);
 ind=find(list(:,1)<mz*(1+ppm));
 list=list(ind,:);
 out=0;sig=0;rt_fix=rt;
 
 
 if ~isempty(list)
     [rts,id]=min(abs(list(:,2)-rt));
     if rts<0.6
         rt_fix=list(id,2);
 
 
[~,intensity,~]=EIC(M,pk,settings);

intensity=log10(intensity+1e-5); % add small value to avoid lg0.

for i=1:3
    m(i)=mean(intensity(i*3-2:i*3));
    err(i)=std(intensity(i*3-2:i*3));
end
diff1=(m(2)- m(1))/mean(err); %use the averaged std
diff2=(m(3)- m(1))/mean(err);
out=[diff1,diff2];
sig=intensity;  % array of signals (0v, 2v, 4v)
     end
 end
end




