function getpot(clmname,grdname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Pierrick 2004
%  Get potential temperature of seawater from insitu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% open the grid file  
% 
nc=netcdf(grdname);
h=nc{'h'}(:);
close(nc);
%
% open the clim file  
% 
nc=netcdf(clmname,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
hc  =  nc{'hc'}(:);
N =  length(nc('s_rho'));
tlen =  length(nc('tclm_time'));
if tlen==0
  tlen=1;
end
%
% Get the sigma depths
%
P=-1e-4*1025*9.81*zlevs(h,0.*h,theta_s,theta_b,hc,N,'r');
%
% loop on time
%
for l=1:tlen
  disp([' Time index: ',num2str(l),' of total: ',num2str(tlen)])
  T=squeeze(nc{'temp'}(l,:,:,:));
  S=squeeze(nc{'salt'}(l,:,:,:));
  nc{'temp'}(l,:,:,:)=theta(S,T,P);
end
close(nc);
return
