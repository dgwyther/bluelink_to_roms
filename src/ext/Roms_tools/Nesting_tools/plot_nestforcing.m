function plot_nestforcing(child_frc,thefield,thetime,skip)
%
% Test the embedded forcing file.
%
% Pierrick Penven 2004
%
npts=[0 0 0 0];
i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime),i)


  nc=netcdf(child_frc);
  parent_frc=nc.parent_file(:);
  child_grd=nc.grd_file(:);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  if thefield(1:3)=='spd'
    fieldc=sqrt((u2rho(u)).^2+(v2rho(v)).^2);
    fieldname='wind speed';
  else
    fieldc=nc{thefield}(time,:,:);
    fieldname=nc{thefield}.long_name(:);
  end
  result=close(nc);

  nc=netcdf(child_grd);
  parent_grd=nc.parent_grid(:);
  refinecoeff=nc{'refine_coef'}(:);
  lonc=nc{'lon_rho'}(:);
  latc=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,maskred]=...
  uv_vec2rho(u,v,lonc,latc,angle,mask,skip*refinecoeff,npts);
  pcolor(lonc,latc,mask.*fieldc)
  shading interp
  axis image
  caxis([min(min(fieldc)) max(max(fieldc))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lonc)) max(max(lonc)) min(min(latc)) max(max(latc))])


  subplot(2,length(thetime),i+length(thetime))

  nc=netcdf(parent_frc);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  if thefield(1:3)=='spd'
    field=sqrt((u2rho(u)).^2+(v2rho(v)).^2);
    fieldname='wind speed';
  else
    field=nc{thefield}(time,:,:);
    fieldname=nc{thefield}.long_name(:);
  end
  result=close(nc);
  nc=netcdf(parent_grd);
  lon=nc{'lon_rho'}(:);
  lat=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,maskred]=...
  uv_vec2rho(u,v,lon,lat,angle,mask,skip,npts);
  pcolor(lon,lat,mask.*field)
  shading interp
  axis image
  caxis([min(min(fieldc)) max(max(fieldc))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lonc)) max(max(lonc)) min(min(latc)) max(max(latc))])
end


return



