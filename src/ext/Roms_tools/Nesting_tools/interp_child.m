function handles=interp_child(h,handles);
%
% Get everything in order to compute the child grid
%
% Pierrick Penven 2004
%

%
% Get the parent grid name
%
if isempty(handles.parentgrid)
  handles=get_parentgrdname(h,handles);
end
%
% Get the sub domain
%
% cae change:  handles.imin seem to be written in get_parentgrdname.
%handles.imin=[];
%keyboard
% end cae change
if isempty(handles.imin)
  handles=get_findgridpos(h,handles);
end
%
% Get the child grid name
%
lev=str2num(handles.parentgrid(end));
if isempty(lev) 
  childname=[handles.parentgrid,'.1'];
else
  childname=[handles.parentgrid(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child grid name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childgrid=childname;
end
%
% Get the topo Name
%
if handles.newtopo==1
  if isempty(handles.toponame)
    handles=get_topofile(h,handles);
  end
end
%
% Get the rfactor and the width of the connection band
%
handles=get_rfactor(h,handles);
handles=get_nband(h,handles);
%
% Perform the interpolations
%
nested_grid(handles.parentgrid,handles.childgrid,...
            handles.imin,handles.imax,handles.jmin,handles.jmax,...
            handles.rcoeff,handles.toponame,handles.newtopo,handles.rfactor,...
            handles.nband,handles.hmin,handles.matchvolume)
%
% Plot the river
%	    
if (~isempty(handles.Isrcparent)) & ~(isempty(handles.Jsrcparent))
  disp('   Plot the river')
  nc=netcdf(handles.parentgrid);
  lon_src=nc{'lon_rho'}(handles.Jsrcparent+1,handles.Isrcparent+1);
  lat_src=nc{'lat_rho'}(handles.Jsrcparent+1,handles.Isrcparent+1);
  close(nc);
  hold on
  h1=plot(lon_src,lat_src,'s',...
                'LineWidth',1.5,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','b',...
                'MarkerSize',10);
  nc=netcdf(handles.childgrid);
  lon_src=nc{'lon_rho'}(handles.Jsrcchild+1,handles.Isrcchild+1);
  lat_src=nc{'lat_rho'}(handles.Jsrcchild+1,handles.Isrcchild+1);
  close(nc);
  h2=plot(lon_src,lat_src,'o',...
                'LineWidth',1.5,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','m',...
                'MarkerSize',7);
  hold off
end
return
