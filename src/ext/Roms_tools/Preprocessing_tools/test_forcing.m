function test_forcing(frcname,grdname,thefield,thetime,skip)

i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime)/2,i)


  nc=netcdf(frcname);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  stime=nc{'sms_time'}(time);
  if thefield(1:3)=='spd'
    field=sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
    fieldname='wind speed';
  else
    field=nc{thefield}(time,:,:);
    fieldname=nc{thefield}.long_name(:);
  end
  result=close(nc);

  nc=netcdf(grdname);
  lon=nc{'lon_rho'}(:);
  lat=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,speed]=uv_vec2rho(u,v,lon,lat,angle,...
                                             mask,skip,[0 0 0 0]);
if 1==1
  pcolor(lon,lat,mask.*field)
  shading interp
  axis image
%  caxis([min(min(field)) max(max(field))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))])
  title([fieldname,' - day: ',num2str(stime)])
else
 imagesc(mask.*field)
   title([fieldname,' - day: ',num2str(stime)])

end

end


