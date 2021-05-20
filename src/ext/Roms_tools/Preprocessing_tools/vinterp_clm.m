function vinterp(clmname,grdname,oaname,vname,tname,zname,tini,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2003
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% open the grid file  
% 
ng=netcdf(grdname);
h=ng{'h'}(:);
close(ng);
%
% open the clim file  
% 
nc=netcdf(clmname,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
hc  =  nc{'hc'}(:);
N =  length(nc('s_rho'));
%
% open the oa file  
% 
noa=netcdf(oaname);
z=-noa{zname}(:);
t=noa{tname}(:);
tlen=length(t);
%
% Get the sigma depths
%
zroms=zlevs(h,0.*h,theta_s,theta_b,hc,N,'r');
if type=='u'
  zroms=rho2u_3d(zroms);
end
if type=='v'
  zroms=rho2v_3d(zroms);
end
zmin=min(min(min(zroms)));
zmax=max(max(max(zroms)));
%
% Check if the min z level is below the min sigma level 
%    (if not add a deep layer)
%
addsurf=max(z)<zmax;
addbot=min(z)>zmin;
if addsurf
 z=[100;z];
end
if addbot
 z=[z;-100000];
end
Nz=min(find(z<zmin));
z=z(1:Nz);
%
% loop on time
%
if tini ~= 0  % initial file 
  tlen=1;
end
for l=1:tlen
%for l=1:1
  if tini == 0
    disp([' Time index: ',num2str(l),' of total: ',num2str(tlen)])
  else
    tini
    ll=find(t<=tini); l=ll(1);
    disp([' Time index: ',num2str(l)])
  end
  var=squeeze(noa{vname}(l,:,:,:));
  if addsurf
    var=cat(1,var(1,:,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:,:));
  end
  var=var(1:Nz,:,:);
  if tini == 0
    nc{vname}(l,:,:,:)=ztosigma(flipdim(var,1),zroms,flipud(z));
  else
    nc{vname}(1,:,:,:)=ztosigma(flipdim(var,1),zroms,flipud(z));
  end
end
close(nc);
close(noa);
return
