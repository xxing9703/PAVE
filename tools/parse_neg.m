% load all mzXML files in the correct sequence using UI file selector parse them into matlab structure.

%% parse negative
fprintf('-----load negative .mzXML data files\n');
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

M = mzxml2struct(pathname,filename);

filter = {'*.mat'};
[file, pathname] = uiputfile([pathname,'*.mat']);
save(fullfile(pathname,file),'M');

