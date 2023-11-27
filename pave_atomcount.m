% This function identifies biological peaks of any given (mz,rt) 
% and finds its C N numbers based on the raw data
% pks: peak structure, must have assigned .mz and .rt
% settings: must be initilzed with all fields,see pave_main.m
% M - raw data structure
% rep: replica in each sample: [3 3 3 3 2]
function [pks,idx]=pave_atomcount(M,pks,settings,rep)
C=1.003355; %13C-12C
N=0.997035; %15N-14N
count=0;idx=[];
sz=length(pks);
for num=1:sz
    pk=pks(num);   %tp
    mz=pks(num).mz;
    C_max=floor(mz/14); %maximum C number
    N_max=10;  %maximum N number
    P=mypattern(rep);
    C_num=0;
    N_num=0;
    
    scoremat=zeros(N_max+1,C_max);% N_num=0~10; C_num=1~C_max
    [~,I1,~]=EIC(M,pk,settings);
    I1=I1(1:sum(rep));
    sig=log10(max(I1(1:rep(1)))+1);
    
    [pt,~]=pattern_finder(P,I1,settings.threshold);
    
% case 1, C/N contained compounds:
if pt==1
    possible_N=[];
    possible_C=[];
    I2=[];I3=[];
  %find all possible N numbers  
  for i=1:N_max
     mz_N=mz+i*N;
     pk.mz=mz_N;
     [~,I,~]=EIC(M,pk,settings);
     n=pattern_finder(P,I,settings.threshold);
     if n==2
         possible_N=[possible_N,i];
         I2=[I2,I];
     end
  end
  %find all possible C numbers
  for i=1:C_max
    mz_C=mz+i*C;
    pk.mz=mz_C;
    [~,I,~]=EIC(M,pk,settings);
    n=pattern_finder(P,I,settings.threshold);
    if n==3
         possible_C=[possible_C,i];
         I3=[I3,I];
    end    
  end
  
  %calculate scores
    for i=1:length(possible_N)
       for j=1:length(possible_C)
           mz_CN=mz+possible_N(i)*N+possible_C(j)*C;
           pk.mz=mz_CN;
           [~,I4,~]=EIC(M,pk,settings);
           n=pattern_finder(P,I4,settings.threshold);
           
           PA=[P{1};P{2};P{3};P{4}];
           Imat=[I1,I2(:,i),I3(:,j),I4];
           R=corrcoef(Imat',PA);
           scoremat(possible_N(i)+1,possible_C(j))=R(1,2);           
       end
    end 
        
elseif pt==5
   possible_C=[];
   for i=1:C_max
    mz_C=mz+i*C;
    pk.mz=mz_C;
    [~,I,~]=EIC(M,pk,settings);
    n=pattern_finder(P,I,settings.threshold);
    if n==6
         possible_C=[possible_C,i];
         I6=I;
         PB=[P{5};P{5};P{6};P{6}];
         Imat=[I1,I1,I6,I6];
         R=corrcoef(Imat',PB);
         scoremat(1,i)=R(1,2);
    end    
   end
else       
end

[score,~]=max(scoremat(:));
if score>0
    [a, b]=max(scoremat);
    [~,C_num]=max(a);  %find C_num
    N_num=b(C_num)-1;  %find N_num
end

pks(num).feature='';
pks(num).sig=sig;
pks(num).N_num=N_num;
pks(num).C_num=C_num;
pks(num).score=max(max(scoremat));
pks(num).scoremat=scoremat;


  if C_num==0
    pks(num).feature='Background';
  elseif score<settings.scorecutoff
    pks(num).feature='Low_score';
  else
      count=count+1;
      idx=[idx,num];
  end
  if settings.verbose==1
   fprintf(['atomcount: ',num2str(count),'/',num2str(num),'/',num2str(length(pks)),'\n'])
  end
end

%-----------------------





