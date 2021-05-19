function ndata = roms_interp(lon, lat, data, ilon, ilat)

%
% function idata = roms_interp(lon, lat, data, ilon, ilat)
%
% Formats data to use interp2 to greatly speed up interpolation
%

if isvector(lon)
  [lon,lat]=meshgrid(lon,lat);
end
if isvector(ilon)
  [ilon,ilat]=meshgrid(ilon,ilat);
end

ri=size(lon,2);
rj=size(lat,1);
[ii,jj]=meshgrid(1:ri,1:rj);
ib=griddata(lon,lat,ii,ilon,ilat,'linear');
jb=griddata(lon,lat,jj,ilon,ilat,'linear');

% Check if we are "looping" around
loop=false;
d=diff(ib(1,:));
if ~isempty(find(d<0))
  tl=lon(1,:);
  til=ilon(1,:);
  ll=max(find(tl<min(til)-10));
  lon=[tl(ll:end) tl(1:ll-1)];
  [lon,tl]=meshgrid(lon,1:rj);
  ib=griddata(lon,lat,ii,ilon,ilat);
  loop=true;
end
if ndims(data)==3
  progress(0,0,1);
  for i=1:size(data,1),
    progress(size(data,1),i,1);
    if loop
      ndata(i,:,:)=interp2(ii,jj,[squeeze(data(i,:,ll:end)) squeeze(data(i,:,1:ll-1))],ib,jb,'linear',0);
    else
      ndata(i,:,:)=interp2(ii,jj,squeeze(data(i,:,:)),ib,jb,'linear',0);
    end
  end
else
  if loop
    ndata(i,:,:)=interp2(ii,jj,[data(i,:,ll:end) data(i,:,1:ll-1)],ib,jb,'linear',0);
  else
    ndata=interp2(ii,jj,data(:,:),ib,jb,'linear',0);
  end
end
