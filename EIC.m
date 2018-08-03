%usage: [spectra,intensity,rt]=EIC(M,pk,settings)
%M is an array of structure containing multi MS raw data 

function [spectra,intensity,rt]=EIC(M,pk,settings)
%M is an array of structure, use M(i).filename, M(i).data to retrieve data
num_file=length(M);
spectra=cell(num_file,1);
intensity=zeros(num_file,1);
rt=zeros(num_file,1);
for j=1:num_file
     signal=slice(M(j).data,pk,settings);  %slice of EIC curve, (rt vs int)
     signal(:,3)=smooth(signal(:,2),settings.ave);  %moving average, stored in 3rd col.
     spectra{j}=signal;  %store all the EIC curves.
     [peak,loc]=findpeaks(signal(:,3),sort(signal(:,1)+rand(size(signal,1),1)/1e7),...%avoid identical x
     'MinPeakProminence',settings.prominence,...  %threshold
     'MinPeakWidth',settings.peakwidth);    %peakwidth
        if isempty(peak)
            peak=0;loc=pk.rt;  %if nothing is found, set intensity=0 and rt=original rt
        end
      [~,ind]=max(peak); %find max peak      
      intensity(j)=peak(ind);   %max intensity
      rt(j)=loc(ind);  %rt location at max 
      
      %[~,loc]=max(signal(:,3));
      %intensity(j)=signal(loc,3);   %max intensity
      
          
end  
end

function signal=slice(mat,pk,settings)
rt_array=cell2mat(mat(:,1));
ind = find(abs(rt_array-pk.rt)<settings.rtm);
dm=pk.mz*settings.ppm;
dm=min(dm,0.005); %restrict the resolution to resolve 13C-15N: (1.00335-0.997)
for i=ind(1):ind(end)
mass=mat{i,2};
intensity=mat{i,3};
ind_mz=find(abs(mass-pk.mz)<dm);
sig(i)=sum(intensity(ind_mz));
    
end
signal=[rt_array(ind),sig(ind)'];
end

%pk.mz=(list(2,1));
%pk.rt=(list(2,2));
%pk.ppm=1e-5;
%pk.rtm=0.3;

