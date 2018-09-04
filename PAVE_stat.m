% ------stat on feature
[cats,~,J]=unique({pks.feature});
occ = histc(J, 1:numel(cats));
stat_feature=[cats',num2cell(occ)];

% ---------stat on all adducts
tp=pks(find(~cellfun(@isempty,{pks.description})));
[cats, ~, J]=unique({tp.description});
occ = histc(J, 1:numel(cats));
stat_add=[cats',num2cell(occ)];
