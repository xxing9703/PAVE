function P=mypattern(rep)
%rep=[3 3 3 3 2]; %replica in 4 conditions and blank
%constructing patterns
on=[];off=[];
for i=1:5
  on{i}=ones(1,rep(i));
  off{i}=zeros(1,rep(i));
end

P{1}=[on{1},off{2},off{3},off{4},off{5}];
P{2}=[off{1},on{2},off{3},off{4},off{5}];
P{3}=[off{1},off{2},on{3},off{4},off{5}];
P{4}=[off{1},off{2},off{3},on{4},off{5}];
P{5}=[on{1},on{2},off{3},off{4},off{5}];
P{6}=[off{1},off{2},on{3},on{4},off{5}];

P_A=[P{1};P{2};P{3};P{4}]; %case A, N>0
P_B=[P{5};P{5};P{6};P{6}]; %case B, N=0


