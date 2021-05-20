function nested_clim(child_grd,parent_clim,child_clim,...
                     vertical_correc,extrapmask,biol)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the climatology of the embedded grid
%
% Pierrick Penven 2004
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
title=['Climatology file for the embedded grid :',child_clim,...
' using parent forcing file: ',parent_clim];
disp(' ')
disp(title)
%
if vertical_correc==1
 disp('Vertical corrections: on')
end
if extrapmask==1
 disp('Under mask extrapolations: on')
end
if biol==1
 disp('Biology: on')
end
%
% Read in the embedded grid
%
disp(' ')
disp(' Read in the embedded grid...')
nc=netcdf(child_grd);
parent_grd=nc.parent_grid(:);
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
refinecoeff=nc{'refine_coef'}(:);
result=close(nc);
nc=netcdf(parent_grd);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
if extrapmask==1
  mask=nc{'mask_rho'}(:);
else
  mask=[];
end
result=close(nc);
%
% Read in the parent climatology file
%
disp(' ')
disp(' Read in the parent climatology file...')
nc = netcdf(parent_clim);
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N = length(nc('s_rho'));
ttime = nc{'tclm_time'}(:);
tcycle = nc{'tclm_time'}.cycle_length(:);
stime = nc{'sclm_time'}(:);
scycle = nc{'sclm_time'}.cycle_length(:);
utime = nc{'ssh_time'}(:);
ucycle = nc{'ssh_time'}.cycle_length(:);
vtime = nc{'ssh_time'}(:);
vcycle = nc{'ssh_time'}.cycle_length(:);
sshtime = nc{'ssh_time'}(:);
sshcycle = nc{'ssh_time'}.cycle_length(:);
result=close(nc);
climtime=ttime;
if stime~=climtime | utime~=climtime | vtime~=climtime | sshtime~=climtime
  error('Nested_clim: different times... ')
end
%
% Create the climatology file
%
disp(' ')
disp(' Create the climatology file...')
ncclim=create_nestedclim(child_clim,child_grd,parent_clim,title,...
                     theta_s,theta_b,Tcline,N,...
                     ttime,stime,utime,vtime,sshtime,...
                     tcycle,scycle,ucycle,vcycle,sshcycle,'clobber');
%
% parent indices
%
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% the children indices
%
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
[ichildgrd_u,jchildgrd_u]=meshgrid(ipchild,jrchild);
[ichildgrd_v,jchildgrd_v]=meshgrid(irchild,jpchild);
%
% interpolations
% 
disp(' ')
disp(' Do the interpolations...')                     
np=netcdf(parent_clim);
disp('u...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',mask,tindex,N)
end
disp('v...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',mask,tindex,N)
end
disp('zeta...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar3d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'SSH',mask,tindex)
end
disp('ubar...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar3d(np,ncclim,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',mask,tindex)
end
disp('vbar...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar3d(np,ncclim,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',mask,tindex)
end
disp('temp...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'temp',mask,tindex,N)
end
disp('salt...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'salt',mask,tindex,N)
end
close(np);
close(ncclim);
%
%  Vertical corrections
%
if (vertical_correc==1)
  for tindex=1:length(climtime)
    disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))])                     
    vert_correc(child_clm,tindex,biol)
  end
end
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
figure(1)
plot_nestclim(child_clim,child_grd,'temp',4)
return
