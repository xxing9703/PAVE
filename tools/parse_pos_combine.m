% You need to load all the mzXML files using UI file selector and store them in M.
clear
[filename, pathname] = ...
     uigetfile('*.mzXML','File Selector','MultiSelect','on');
for i=1:size(filename,2)
    A(i)=importdata(fullfile(pathname,filename{i}));
end

for f=1:size(A,2)
    ct=0;
   for i=1:2:floor(length(A(f).scan)/2)*2
    ct=ct+1;   
    rt_str=A(f).scan(i).retentionTime; %rt time
    rt1=str2num(rt_str(3:end-1))/60;
    rt_str=A(f).scan(i+1).retentionTime; %rt time
    rt2=str2num(rt_str(3:end-1))/60;
    
    mat{ct,1}=(rt1+rt2)/2;
    
    
    pair=A(f).scan(i).peaks.mz;%mass-inten pair
    mz1=pair(1:2:length(pair)-1);
    inten1=pair(2:2:length(pair));
    pair=A(f).scan(i+1).peaks.mz;%mass-inten pair
    mz2=pair(1:2:length(pair)-1);
    inten2=pair(2:2:length(pair));
    
    
    mat{ct,2}=[mz2;mz1];
    mat{ct,3}=[inten2;inten1];
   end
    M(f).filename=filename{f};
    M(f).data=mat;
end
[filename, pathname] = ...
     uiputfile([pathname,'*.mat'],'save as .mat');
save(fullfile(pathname,filename),'M');
