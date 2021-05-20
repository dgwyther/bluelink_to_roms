function data_new=change_sigma(lon,lat,mask,data_old,z_old,z_new)
%
% Reinterpolate the variables to fit on the new vertical s-coordinates
% (for a new topography)
%
% Pierrick Penven 2004
%
m1=mask;
m1(m1==0)=NaN;
[N,M,L]=size(data_old);
%
% Get the horizontal levels (i.e. the zigma levels
% at the deepest depth)
%
zmin=min(min(min(z_old)));
zmax=max(max(max(z_old)));
[j,i]=find(squeeze(z_old(1,:,:))==zmin);
deepval=data_old(1,j,i);
depth=[500*(floor(zmin/500))-2000;z_old(:,j,i);10];
Nd=length(depth);
data_z=zeros(Nd,M,L);
%
% Extract a z variable
%
for k=1:Nd
  disp(['  computing depth = ',num2str(depth(k))])
  data2d=m1.*vinterp(data_old,z_old,depth(k));
%
% Horizontal extrapolation using 'nearest' ...
%
  isbad=isnan(data2d);
  isgood=~isbad;
  if sum(sum(isgood))==0
    data_z(k,:,:)=deepval;
  elseif sum(sum(isgood))==1
    data_z(k,:,:)=data2d(isgood);
  elseif sum(sum(isbad))==0
    data_z(k,:,:)=data2d;
  else
    data2d(isbad)=griddata(lon(isgood),lat(isgood),data2d(isgood),...
                           lon(isbad),lat(isbad),'nearest');
    data_z(k,:,:)=mask.*data2d;			 
  end
end
%
% Interpole on new sigma levels 
%
data_new=ztosigma(data_z,z_new,depth);
%
return
