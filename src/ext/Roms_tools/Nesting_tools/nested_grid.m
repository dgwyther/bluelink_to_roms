function nested_grid(parent_grd,child_grd,imin,imax,jmin,jmax,refinecoeff,...
                     topofile,newtopo,rtarget,nband,hmin,matchvolume)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the embedded grid
%
% Pierrick Penven 2004
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% file_title
%
file_title=['Grid embedded in ',parent_grd,...
            ' - positions in the parent grid: ',num2str(imin),' - ',...
num2str(imax),' - ',...
num2str(jmin),' - ',...
num2str(jmax),'; refinement coefficient : ',num2str(refinecoeff)];
disp(file_title)
%
% Read in the parent grid
%
disp(' ')
disp(' Read in the parent grid...')
nc=netcdf(parent_grd);
latp_parent=nc{'lat_psi'}(:);
lonp_parent=nc{'lon_psi'}(:);
xp_parent=nc{'x_psi'}(:);
yp_parent=nc{'y_psi'}(:);
maskp_parent=nc{'mask_psi'}(:);
%
latu_parent=nc{'lat_u'}(:);
lonu_parent=nc{'lon_u'}(:);
xu_parent=nc{'x_u'}(:);
yu_parent=nc{'y_u'}(:);
masku_parent=nc{'mask_u'}(:);
%
latv_parent=nc{'lat_v'}(:);
lonv_parent=nc{'lon_v'}(:);
xv_parent=nc{'x_v'}(:);
yv_parent=nc{'y_v'}(:);
maskv_parent=nc{'mask_v'}(:);
%
latr_parent=nc{'lat_rho'}(:);
lonr_parent=nc{'lon_rho'}(:);
xr_parent=nc{'x_rho'}(:);
yr_parent=nc{'y_rho'}(:);
maskr_parent=nc{'mask_rho'}(:);
%
h_parent=nc{'h'}(:);
f_parent=nc{'f'}(:);
angle_parent=nc{'angle'}(:);
pm_parent=nc{'pm'}(:);
pn_parent=nc{'pn'}(:);
%
close(nc);
%
if isempty(hmin) | newtopo==0
  hmin = min(min(h_parent));
end
disp(' ')
disp(['  hmin = ',num2str(hmin)])
%
% Parent indices
%
[Mp,Lp]=size(h_parent);
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% Test if correct 
%
if imin>=imax
  error(['imin >= imax - imin = ',...
         num2str(imin),' - imax = ',num2str(imax)])
end
if jmin>=jmax
  error(['jmin >= jmax - jmin = ',...
         num2str(jmin),' - jmax = ',num2str(jmax)])
end
if jmax>(Mp-1)
  error(['jmax > M - M = ',...
         num2str(Mp-1),' - jmax = ',num2str(jmax)])
end
if imax>(Lp-1)
  error(['imax > L - L = ',...
         num2str(Lp-1),' - imax = ',num2str(imax)])
end
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
lonpchild=interp2(igrd_p,jgrd_p,lonp_parent,ichildgrd_p,jchildgrd_p,'cubic');
latpchild=interp2(igrd_p,jgrd_p,latp_parent,ichildgrd_p,jchildgrd_p,'cubic');
xpchild=interp2(igrd_p,jgrd_p,xp_parent,ichildgrd_p,jchildgrd_p,'cubic');
ypchild=interp2(igrd_p,jgrd_p,yp_parent,ichildgrd_p,jchildgrd_p,'cubic');
%
lonuchild=interp2(igrd_u,jgrd_u,lonu_parent,ichildgrd_u,jchildgrd_u,'cubic');
latuchild=interp2(igrd_u,jgrd_u,latu_parent,ichildgrd_u,jchildgrd_u,'cubic');
xuchild=interp2(igrd_u,jgrd_u,xu_parent,ichildgrd_u,jchildgrd_u,'cubic');
yuchild=interp2(igrd_u,jgrd_u,yu_parent,ichildgrd_u,jchildgrd_u,'cubic');
%
lonvchild=interp2(igrd_v,jgrd_v,lonv_parent,ichildgrd_v,jchildgrd_v,'cubic');
latvchild=interp2(igrd_v,jgrd_v,latv_parent,ichildgrd_v,jchildgrd_v,'cubic');
xvchild=interp2(igrd_v,jgrd_v,xv_parent,ichildgrd_v,jchildgrd_v,'cubic');
yvchild=interp2(igrd_v,jgrd_v,yv_parent,ichildgrd_v,jchildgrd_v,'cubic');
%
lonrchild=interp2(igrd_r,jgrd_r,lonr_parent,ichildgrd_r,jchildgrd_r,'cubic');
latrchild=interp2(igrd_r,jgrd_r,latr_parent,ichildgrd_r,jchildgrd_r,'cubic');
xrchild=interp2(igrd_r,jgrd_r,xr_parent,ichildgrd_r,jchildgrd_r,'cubic');
yrchild=interp2(igrd_r,jgrd_r,yr_parent,ichildgrd_r,jchildgrd_r,'cubic');
%
anglechild=interp2(igrd_r,jgrd_r,angle_parent,ichildgrd_r,jchildgrd_r,'cubic');
fchild=interp2(igrd_r,jgrd_r,f_parent,ichildgrd_r,jchildgrd_r,'cubic');
h_parent_fine=interp2(igrd_r,jgrd_r,h_parent,ichildgrd_r,jchildgrd_r,'cubic');
%
h_coarse=interp2(igrd_r,jgrd_r,h_parent,ichildgrd_r,jchildgrd_r,'nearest');
maskr_coarse=interp2(igrd_r,jgrd_r,maskr_parent,ichildgrd_r,jchildgrd_r,'nearest');
pm_coarse=interp2(igrd_r,jgrd_r,pm_parent,ichildgrd_r,jchildgrd_r,'nearest');
pn_coarse=interp2(igrd_r,jgrd_r,pn_parent,ichildgrd_r,jchildgrd_r,'nearest');
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[Mchild,Lchild]=size(latpchild);
create_nestedgrid(Lchild,Mchild,child_grd,parent_grd,file_title)
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
nc=netcdf(child_grd,'write');
nc{'refine_coef'}(:)=refinecoeff;
nc{'grd_pos'}(:) = [imin,imax,jmin,jmax];
nc{'lat_u'}(:)=latuchild;
nc{'lon_u'}(:)=lonuchild;
nc{'x_u'}(:)=xuchild;
nc{'y_u'}(:)=yuchild;
%
nc{'lat_v'}(:)=latvchild;
nc{'lon_v'}(:)=lonvchild;
nc{'x_v'}(:)=xvchild;
nc{'y_v'}(:)=yvchild;
%
nc{'lat_rho'}(:)=latrchild;
nc{'lon_rho'}(:)=lonrchild;
nc{'x_rho'}(:)=xrchild;
nc{'y_rho'}(:)=yrchild;
%
nc{'lat_psi'}(:)=latpchild;
nc{'lon_psi'}(:)=lonpchild;
nc{'x_psi'}(:)=xpchild;
nc{'y_psi'}(:)=ypchild;
%
nc{'hraw'}(1,:,:)=h_parent_fine;
nc{'angle'}(:)=anglechild;
nc{'f'}(:)=fchild;
nc{'spherical'}(:)='T';
%
close(nc);
%
%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=get_metrics(child_grd);
%
%  Add topography
%
disp(' ')
if newtopo==1
  disp(' Add topography...')
  hetopo=add_topo(child_grd,topofile);
  hnew=hetopo;
else
  disp(' Just interp parent topography...')
  hnew=h_parent_fine;
end
%
% Compute the mask
%
maskrchild=get_embeddedmask(maskr_coarse,hnew,refinecoeff,newtopo);
[maskuchild,maskvchild,maskpchild]=uvp_mask(maskrchild);
%
%  Smooth the topography
%
if newtopo==1
  hnew = smoothgrid(hnew,hmin,rtarget);
  disp(' ')
  disp(' Connect the topography...')
  [hnew,alph]=connect_topo(hnew,h_parent_fine,h_coarse,maskrchild,maskr_coarse,...
                           pm_coarse,pn_coarse, ...
                           pm,pn,nband,refinecoeff,matchvolume);
else
  alph=1+0.*hnew;
  if matchvolume==1
    hnew=connect_volume(hnew,h_coarse,maskr_coarse,...
                        pm_coarse,pn_coarse,...
                        pm,pn,refinecoeff);
  end
end
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
nc=netcdf(child_grd,'write');
nc{'h'}(:)=hnew;
nc{'pm'}(:)=pm;
nc{'pn'}(:)=pn;
nc{'dndx'}(:)=dndx;
nc{'dmde'}(:)=dmde;
nc{'mask_u'}(:)=maskuchild;
nc{'mask_v'}(:)=maskvchild;
nc{'mask_psi'}(:)=maskpchild;
nc{'mask_rho'}(:)=maskrchild;
close(nc);
disp(' ')
disp(['  Size of the grid:  L = ',...
      num2str(Lchild),' - M = ',num2str(Mchild)])
%
% make a plot
%
disp(' ')
disp(' Do a plot...')
lonbox=cat(1,lonp_parent(jmin:jmax,imin),  ...
                lonp_parent(jmax,imin:imax)' ,...
                lonp_parent(jmax:-1:jmin,imax),...
                lonp_parent(jmin,imax:-1:imin)' );
latbox=cat(1,latp_parent(jmin:jmax,imin),  ...
                latp_parent(jmax,imin:imax)' ,...
                latp_parent(jmax:-1:jmin,imax),...
                latp_parent(jmin,imax:-1:imin)' );
loncbox=cat(1,lonpchild(1:Mchild,1),  ...
                lonpchild(Mchild,1:Lchild)' ,...
                lonpchild(Mchild:-1:1,Lchild),...
                lonpchild(1,Lchild:-1:1)' );
latcbox=cat(1,latpchild(1:Mchild,1),  ...
               latpchild(Mchild,1:Lchild)' ,...
                latpchild(Mchild:-1:1,Lchild),...
                latpchild(1,Lchild:-1:1)' );
figure(1)
% cae change here
%themask=maskrchild;
themask=double(maskrchild);
themask(maskrchild==0)=NaN;
%contourf(lonrchild,latrchild,themask.*alph,[0:0.1:1])
pcolor(lonrchild,latrchild,themask.*alph)
caxis([0 1])
shading flat
colorbar
axis image 
hold on
[C1,h1]=contour(lonrchild,latrchild,hnew,...
                [10 100 200 500 1000 2000 4000],'y');
[C2,h2]=contour(lonrchild,latrchild,h_parent_fine,...
                [10 100 200 500 1000 2000 4000],'k');
if newtopo==1
  [C3,h3]=contour(lonrchild,latrchild,hetopo,...
                [10 100 200 500 1000 2000 4000],'b');
end
[C4,h4]=contour(lonrchild,latrchild,maskrchild,[0.5 0.5],'r');
[C5,h5]=contour(lonrchild,latrchild,maskr_coarse,[0.5 0.5],'r:');
h6=plot(lonbox,latbox,'k');
h7=plot(loncbox,latcbox,'y:');
plot(lonrchild(maskr_coarse==0),latrchild(maskr_coarse==0),'k.')
plot(lonrchild(maskrchild==0),latrchild(maskrchild==0),'ro')

% cae comment this out for visibility
%h8=plot(lonr_parent,latr_parent,'g.');
% end cae change
hold off
title('alpha parameter with contours of parent (k), child (y), and topo (b)')
axis([min(min(lonrchild)) max(max(lonrchild)),...
      min(min(latrchild)) max(max(latrchild))])
warning off

%if newtopo==1
%  legend([h1(1),h2(1),h3(1),h4(1),h5(1),h8(1)],...
%  'Child topo','Parent topo','Raw topo','Child mask','Parent mask',...
%  'Parent rho points')
%else
%  legend([h1(1),h2(1),h4(1),h5(1),h8(1)],...
%  'Child topo','Parent topo','Child mask','Parent mask',...
%  'Parent rho points')
%end

warning on
%
% End
%
return
