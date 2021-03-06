function nested_initial(child_grd,parent_ini,child_ini,...
                        vertical_correc,extrapmask,biol)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the initial file of the embedded grid
%
% Pierrick Penven 2004
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tindex=1;
%
% Title
%
title=['Initial file for the embedded grid :',child_ini,...
       ' using parent initial file: ',parent_ini];
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
% Read in the parent initial file
%
disp(' ')
disp(' Read in the parent initial file...')
nc = netcdf(parent_ini);
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N = length(nc('s_rho'));
thetime = nc{'scrum_time'}(:);
result=close(nc);
%
% Create the initial file
%
disp(' ')
disp(' Create the initial file...')
ncini=create_nestedinitial(child_ini,child_grd,parent_ini,title,...
                           theta_s,theta_b,Tcline,N,thetime,'clobber');
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
np=netcdf(parent_ini);
for tindex=1:length(thetime)
  disp('zeta...')
  interpvar3d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'zeta',mask,tindex)
  disp('ubar...')
  interpvar3d(np,ncini,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',mask,tindex)
  disp('vbar...')
  interpvar3d(np,ncini,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',mask,tindex)
  disp('u...')
  interpvar4d(np,ncini,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',mask,tindex,N)
  disp('v...')
  interpvar4d(np,ncini,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',mask,tindex,N)
  disp('temp...')
  interpvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'temp',mask,tindex,N)
  disp('salt...')
  interpvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'salt',mask,tindex,N)
  if (biol==1)
    disp('NO3...')
    interpvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'NO3',mask,tindex,N)
    disp('CHLA...')
    interpvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'CHLA',mask,tindex,N)
    disp('PHYTO...')
    interpvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'PHYTO',mask,tindex,N)
  end
end
result=close(np);
result=close(ncini);
%
%  Vertical corrections
%
if (vertical_correc==1)
  for tindex=1:length(thetime)
    disp([' Time index : ',num2str(tindex),' of ',num2str(length(thetime))])                     
    vert_correc(child_ini,tindex,biol)
  end
end
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
figure(1)
plot_nestclim(child_ini,child_grd,'temp',1)
return

