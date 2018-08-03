%annotate duplicated peaks
function [pk,idx]=pave_find_dup(pks,settings)
fprintf('remove duplicates....')

pk=pks(1); count=1;idx=[];
for i=2:length(pks)    
  if ~inlist(pks(i),pk,settings)
      count=count+1;
      pk(count,1)=pks(i);
      pk(count).id=i;
      idx=[idx,i];
      if settings.verbose==1
          fprintf(['find_dup:',num2str(i-count),'/',num2str(i),'\n']);
      end
  end
end
fprintf(['Done!\n ',num2str(i-count),' duplicates found\n']);

