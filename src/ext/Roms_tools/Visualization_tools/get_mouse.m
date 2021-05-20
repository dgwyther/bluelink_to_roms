function [lon1,lat1,lon2,lat2]=get_mouse(handles)
%--------------------------------------------------------------------
%  Pierriekc 2002
%--------------------------------------------------------------------

set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes1);
m_proj('mercator',...
       'lon',[handles.lonmin handles.lonmax],...
       'lat',[handles.latmin handles.latmax]);
[x1,y1] = ginput(1);
[lon1,lat1]=m_xy2ll(x1,y1);
hold on
plot(x1,y1,'yo')
hold off
[x2,y2] = ginput(1);
[lon2,lat2]=m_xy2ll(x2,y2);
hold on
plot(x2,y2,'yo')
plot([x1 x2],[y1 y2],'r--')
hold off

return
