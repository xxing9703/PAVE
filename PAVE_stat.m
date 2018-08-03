 %convert to table and export
pks_tb.feature(cellfun(@isempty,pks_tb.feature)==1)={'Unknown'}; % fill [] with unknown
[cats, ~, J]=unique(pks_tb.feature);
occ = histc(J, 1:numel(cats));
stat_feature=[cats,num2cell(occ)];  %show statistics 


pks_tb.description(cellfun(@isempty,pks_tb.description)==1)={'N/A'};
[cats, ~, J]=unique(pks_tb.description);
occ = histc(J, 1:numel(cats));
stat_add=[cats,num2cell(occ)];  %show statistics 