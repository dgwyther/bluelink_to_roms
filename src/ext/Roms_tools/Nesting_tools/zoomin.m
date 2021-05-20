function handles=zoomin(h,handles)
%
% Zoom in
%
% Pierrick Penven 2004
%
waitforbuttonpress
xy=get(gca,'currentpoint');
x=xy(1,1);
y=xy(1,2);
[lon1,lat1]=m_xy2ll(x,y);
rbbox  
xy=get(gca,'currentpoint');
x=xy(1,1);
y=xy(1,2);
[lon2,lat2]=m_xy2ll(x,y);
if lon1==lon2 | lat1==lat2
  return
end
%
handles.lonmin=min([lon1 lon2]);
handles.lonmax=max([lon1 lon2]);
handles.latmin=min([lat1 lat2]);
handles.latmax=max([lat1 lat2]);
plot_nestgrid(h,handles)
return
