function handles=get_childgrdname(h,handles)
%
% Get the name of the child grid file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'CHILD GRID');
if isequal([filename,pathname],[0,0])
  return
end
handles.childgrid=fullfile(pathname,filename);
nc=netcdf(handles.childgrid,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file')
  handles.childgrid=[];
  return
end
lon=nc{'lon_rho'}(:);
grdpos=nc{'grd_pos'}(:);
parent=nc.parent_grid(:);
close(nc)
if isempty(grdpos)
  disp('Warning : this is not a child grid file')
  handles.childgrid=[];
  return
end
lmin=min([length(parent) length(handles.parentgrid)]);
if (parent(1:lmin)~=handles.parentgrid(1:lmin)) |...
   (length(parent)~=length(handles.parentgrid))
  Answer=questdlg(['Warning : Are you sure that',handles.childgrid,...
                   ' is a child of ',handles.parentgrid,' ?'],'',...
                   'Yes','No','Yes');
  switch Answer
  case {'No'}
    handles.childgrid=[];
    handles.imin=[];
    handles.imax=[];
    handles.jmin=[];
    handles.jmax=[];
    return
  case 'Yes'
  end
end
handles.imin=grdpos(1);
handles.imax=grdpos(2);
handles.jmin=grdpos(3);
handles.jmax=grdpos(4);
%
handles=update_plot(h,handles);
%
return
