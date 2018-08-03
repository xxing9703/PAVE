%this code finds C, N numbers in each formula of YMDB using
%"formula2mass.m". Choose either of the 2 formats below.
%% spreadsheet method
[~,~,A]=xlsread('Metlin-1.xlsx');
A{1,5}='C_num';
A{1,6}='N_num';

for i=2:size(A,1)
    formula=A{i,3};
   [mass,~,count]=formula2mass(formula);
   A{i,5}=count(1);
   A{i,6}=count(2);   
   A{i,4}=mass;    
end

xlswrite('my_Metlin.xlsx',A);
%% table style method
% A=readtable('ymdb_full.csv');
% for i=1:size(A,1)
%     formula=A{i,3};
%    [mass,~,count]=formula2mass(formula{1});
%    C_num(i,1)=count(1);
%    N_num(i,1)=count(2);   
%    mass(i)=mass;    
% end
% A.C_num=C_num;
% A.N_num=N_num;
% writetable(A,'my_ymdb_full.csv')