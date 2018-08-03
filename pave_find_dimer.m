%need to input adduct structure.
function [pks,idx1,idx2]=pave_find_dimer(M,pks,settings,rep)
H=1.0078;
idx1=[];idx2=[];
factor_lb=1; factor_ub=1;
count=0;c1=0;c2=0;

for num=1:length(pks)
    pk1=pks(num);
    if isempty(pk1.feature) || settings.override==1 
     count=count+1;
     mz1=pk1.mz;
     mz2=(mz1+settings.mode*H)/2;
     pk2.mz=mz2;
     pk2.rt=pk1.rt;
     
     
   % read signal1
    if isempty(pk1.sig)
        [~,I,~]=EIC(M(1:rep(1)),pk1,settings);
        sig1=log10(max(I)+1);
        pk1.sig=sig1;
    else
        sig1=pk1.sig;
    end
    
    % read signal2
    [~,I,~]=EIC(M(1:rep(1)),pk2,settings);
    sig2=log10(max(I)+1);  
    
    % ratio
    ratio=10^(sig2-sig1);   
   
    
    if ratio>1
        c1=c1+1;
        
        pk2=pave_atomcount(M,pk2,settings,rep);
        dC=pk2.C_num*2-pk1.C_num;
        dN=pk2.N_num*2-pk1.N_num;
        
        
       if dC==0 && dN==0 ...%C N match
               && pk2.C_num>0 %parent must be a good peak
        c2=c2+1;
        pks(num).feature='Dimer';
        pks(num).description='Dimer';
        pks(num).parent=pk2;
        idx1=[idx1,num];
        tp=inlist(pk2,pks,settings);
        if tp>0
          idx2=[idx2,tp];
        else
          idx2=[idx2,num]; 
        end
        
        end
    end
     if settings.verbose==1
       fprintf(['Dimer:-- ',num2str(c2),'/',num2str(c1),'/',num2str(count),'\n']);
     end
    end
    
end

