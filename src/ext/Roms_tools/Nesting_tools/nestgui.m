function varargout = nestgui(varargin)
%
%
% NESTGUI Application M-file for nestgui.fig
% 
% GUI to generate embedded ROMS grid, forcing, initial, and restart
% netcdf files 
%
% Pierrick Penven 2004
%
if nargin == 0  % LAUNCH GUI
  fig = openfig(mfilename,'reuse');
  set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
  handles = guihandles(fig);
  guidata(fig, handles);
  parentgrid_Callback(fig, [], handles, varargin)  
  if nargout > 0
    varargout{1} = fig;
  end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  try
  [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
  catch
  disp(lasterr);
  end
end
%
% MENU : OPEN PARENT GRID FILE
%
function varargout = parentgrid_Callback(h, eventdata, handles, varargin)
handles=get_parentgrdname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN CHILD GRID FILE
%
function varargout = childgrid_Callback(h, eventdata, handles, varargin)
handles=get_childgrdname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT FORCING FILE
%
function varargout = parentforcing_Callback(h, eventdata, handles, varargin)
handles=get_parentfrcname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT INITIAL FILE
%
function varargout = parentinitial_Callback(h, eventdata, handles, varargin)
handles=get_parentininame(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN TOPO FILE
%
function varargout = topo_Callback(h, eventdata, handles, varargin)
handles=get_topofile(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT RESTART FILE
%
function varargout = parentrst_Callback(h, eventdata, handles, varargin)
handles=get_parentrstname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT CLIMATOLOGY FILE
%
function varargout = parentclm_Callback(h, eventdata, handles, varargin)
handles=get_parentclmname(h,handles);
guidata(h,handles)
return
%
%  ZOOMS
%
function varargout = zoomin_Callback(h, eventdata, handles, varargin)
handles=zoomin(h,handles);
guidata(h,handles)
return
function varargout = zoomout_Callback(h, eventdata, handles, varargin)
handles=zoomout(h,handles);
guidata(h,handles)
return
%
% Get the child grid position
%
function varargout = findgridpos_Callback(h, eventdata, handles, varargin)
handles=get_findgridpos(h,handles);
guidata(h,handles)
return
%
% L,M
%
function varargout = editLchild_Callback(h, eventdata, handles, varargin)
handles=get_Lchild(h,handles);
guidata(h,handles)
return
function varargout = editMchild_Callback(h, eventdata, handles, varargin)
handles=get_Mchild(h,handles);
guidata(h,handles)
return
%
% IMIN
%
function varargout = edit_imin_Callback(h, eventdata, handles, varargin)
handles=get_imin(h,handles);
guidata(h,handles)
return
%
% IMAX
%
function varargout = edit_imax_Callback(h, eventdata, handles, varargin)
handles=get_imax(h,handles);
guidata(h,handles)
return
%
% JMIN
%
function varargout = edit_jmin_Callback(h, eventdata, handles, varargin)
handles=get_jmin(h,handles);
guidata(h,handles)
return
%
% JMAX
%
function varargout = edit_jmax_Callback(h, eventdata, handles, varargin)
handles=get_jmax(h,handles);
guidata(h,handles)
return
%
% Refinment coefficient
%
function varargout = edit_rcoef_Callback(h, eventdata, handles, varargin)
handles=get_rcoef(h,handles);
guidata(h,handles)
return
%
% r-factor
%
function varargout = editrfactor_Callback(h, eventdata, handles, varargin)
handles=get_rfactor(h,handles);
guidata(h,handles)
return
%
% n-band
%
function varargout = editnband_Callback(h, eventdata, handles, varargin)
handles=get_nband(h,handles);
guidata(h,handles)
return
%
% Hmin
%
function varargout = edithmin_Callback(h, eventdata, handles, varargin)
handles=get_hmin(h,handles);
guidata(h,handles)
return
%
% New topo switch
%
function varargout = newtopo_Callback(h, eventdata, handles, varargin)
handles=get_newtopobutton(h,handles);
guidata(h,handles)
return
%
% Match volume switch
%
function varargout = matchvolume_Callback(h, eventdata, handles, varargin)
handles=get_matchvolumebutton(h,handles);
guidata(h,handles)
return
%
% Interp the child grid
%
function varargout = interpchild_Callback(h, eventdata, handles, varargin)
handles=interp_child(h,handles);
guidata(h,handles)
return
%
% Interp the child forcing
%
function varargout=interpforcing_Callback(h, eventdata, handles, varargin)
handles=interp_forcing(h,handles);
guidata(h,handles)
return
%
% Interp the child initial conditions
%
function varargout=interpinitial_Callback(h, eventdata, handles, varargin)
handles=interp_initial(h,handles);
guidata(h,handles)
return
%
% Interp the child restart conditions
%
function varargout=interprestart_Callback(h, eventdata, handles, varargin)
handles=interp_restart(h,handles);
guidata(h,handles)
return
%
% Interp the child boundary conditions
%
function varargout=interpclim_Callback(h, eventdata, handles, varargin)
handles=interp_clim(h,handles);
guidata(h,handles)
return
%
% Vertical correction switch
%
function varargout = vcorrec_Callback(h, eventdata, handles, varargin)
handles.vertical_correc=1-handles.vertical_correc;
guidata(h,handles)
return
%
%  Extrapolations switch
%
function varargout = extrap_Callback(h, eventdata, handles, varargin)
handles.extrapmask=1-handles.extrapmask;
guidata(h,handles)
return
%
%  Biologie switch
%
function varargout = biologie_Callback(h, eventdata, handles, varargin)
handles.biol=1-handles.biol;
guidata(h,handles)
return
%
% Rivers
%
function varargout = addriver_Callback(h, eventdata, handles, varargin)
handles=get_river(h,handles);
guidata(h,handles)
return
function varargout = edit_Isrcparent_Callback(h, eventdata, handles, varargin)
set(handles.edit_Isrcparent,'String',num2str(handles.Isrcparent));
guidata(h,handles)
return
function varargout = edit_Jsrcparent_Callback(h, eventdata, handles, varargin)
set(handles.edit_Jsrcparent,'String',num2str(handles.Jsrcparent));
guidata(h,handles)
return
function varargout = edit_Isrcchild_Callback(h, eventdata, handles, varargin)
set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
guidata(h,handles)
return
function varargout = edit_Jsrcchild_Callback(h, eventdata, handles, varargin)
set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
guidata(h,handles)
return
