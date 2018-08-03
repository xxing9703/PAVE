% pos mode, scan1 mz=118.5-1000, scan2 mz=70-117.5
% parse positive scan1
fprintf('1-----load positive_scan1 .mzXML data files\n');
[filename, pathname] = ...
     uigetfile('*.mzXML','File Selector','MultiSelect','on');
if iscell(filename)  %multifile selected
elseif filename==0    % no file selected
    warndlg('No files selected'); 
    return    
else   % one file selected
    f{1}=filename;  % convert to cell format
    filename=f;
end

M1 = mzxml2struct(pathname,filename);
% parse positive scan2
fprintf('2-----load positive_scan2 .mzXML data files\n');
[filename, pathname] = ...
     uigetfile([pathname,'*.mzXML'],'File Selector','MultiSelect','on');
if iscell(filename)  %multifile selected
elseif filename==0    % no file selected
    warndlg('No files selected'); 
    return    
else   % one file selected
    f{1}=filename;  % convert to cell format
    filename=f;
end

M2 = mzxml2struct(pathname,filename);

% merge M1 M2 into M
M=[];
if length(M1)==length(M2)
    for i=1:length(M1)
        M(i).filename = M1(i).filename;
        sz = min(size(M1(i).data,1),size(M2(i).data,1));
        for j=1:sz
            M(i).data{j,1}=(M1(i).data{j,1}+M2(i).data{j,1})/2; %avg rt
            M(i).data{j,2}=[M2(i).data{j,2};M1(i).data{j,2}]; %concat mz
            M(i).data{j,3}=[M2(i).data{j,3};M1(i).data{j,3}]; %concat int           
        end
        
    end 
else
     warndlg('# of files for scan 1 and 2 do not match');
     return
end
%filter = {'*.mat'};
[file, path] = uiputfile([pathname,'*.mat']);
save(fullfile(path,file),'M');
