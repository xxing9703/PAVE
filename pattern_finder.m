function [n, c] = pattern_finder(P,intensity,threshold)
n=0; % n=0,1,2,3,4,5,6  different pattern numbers.
c=0; % c is correlation coefficient 
for i=1:6
tp=corrcoef(P{i},intensity);
    if tp(1,2)>threshold && tp(1,2)>c %find the highest c, determine pattern
        n=i;
        c=tp(1,2);
    end
end