function test_forcing(frcname,grdname,thefield,thetime,skip)

i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime)/2,i)

  nc=netcdf(frcname);
  stime=nc{'bulk_time'}(time);
  field=nc{thefield}(time,:,:);
  fieldname=nc{thefield}.long_name(:);
  result=close(nc);

  nc=netcdf(grdname);
  lon=nc{'lon_rho'}(:);
  lat=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  result=close(nc);
  mask(mask==0)=NaN;

if 1==1
  pcolor(lon,lat,mask.*field)
  shading flat
  axis image
%  caxis([min(min(field)) max(max(field))])
  colorbar
  axis([min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))])
  title([fieldname,' - day: ',num2str(stime)])
else
  imagesc(mask.*field)
  title([fieldname,' - day: ',num2str(stime)])
end

end


