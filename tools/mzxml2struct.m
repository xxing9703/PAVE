function M = mzxml2struct(pathname,filenames)

for i=1:size(filenames,2)
    fprintf(['parsing file #',num2str(i),'/',num2str(size(filenames,2)),'\n']);
    A(i)=mzxmlread_xi(fullfile(pathname,filenames{i}));
end

fprintf('converting to M structure\n');
for f=1:size(A,2)
   for i=1:length(A(f).scan)
    rt_str=A(f).scan(i).retentionTime; %rt time
    mat{i,1}=str2num(rt_str(3:end-1))/60;
    pair=A(f).scan(i).peaks.mz;%mass-inten pair
    mz=pair(1:2:length(pair)-1);
    inten=pair(2:2:length(pair));
    mat{i,2}=mz;
    mat{i,3}=inten;
   end
    M(f).filename=filenames{f};
    M(f).data=mat;
end