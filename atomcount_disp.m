function [spec,Imat]=atomcount_disp(M,pk,settings,rep)
%-----------------draw-------------------
C=1.003355; %13C-12C
N=0.997035; %15N-14N
I=[];
if pk.score>0 
    cl='brcmk';
    clr=[repmat('b',1,rep(1)),repmat('r',1,rep(2)),repmat('c',1,rep(3)),repmat('m',1,rep(4)),repmat('k',1,rep(5))];    
    mz(1)=pk.mz;
    mz(2)=pk.mz+pk.N_num*N;
    mz(3)=pk.mz+pk.C_num*C;
    mz(4)=pk.mz+pk.N_num*N+pk.C_num*C;
    
    for i=1:4
        pk.mz=mz(i);
        [spec{i},I{i},~]=EIC(M,pk,settings);
    end
    Imat=[I{1},I{2},I{3},I{4}];
%----start drawing
    figure %FIGURE 1
    b=bar(Imat);
    for i=1:4
      b(i).FaceColor = cl(i) ;
    end
    title(['N=',num2str(pk.N_num),';  C=',num2str(pk.C_num), ';  Score=',num2str(pk.score)]);
    
    figure  %FIGURE 2
    tt={'/','N','C','CN'};
    for i=1:4
    subplot(2,2,i)
      curves=spec{i};
       for j=1:size(curves,1)
         mat=curves{j};
         plot(mat(:,1),mat(:,2),clr(j));
         %ylim([0,max(signal(index,:))*1.1]);
         title(['mz=',num2str(mz(i))]);
         legend(tt{i});
         hold on
       end
    end    

end