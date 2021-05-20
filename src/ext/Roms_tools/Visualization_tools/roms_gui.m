function varargout = roms_gui(varargin)
% ROMS_GUI Application M-file for roms_gui.fig
if nargin == 0  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Use system color scheme for figure:
  set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it. 
  handles = guihandles(fig);
  
  hisfile_callback(fig, [], handles, varargin)  
  
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
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
% Callback for Open Coastfile
% ------------------------------------------------------------
function varargout = coastfile_callback(h, eventdata, handles, varargin)
% Use UIGETFILE to allow for the selection of a custom address book.
[filename, pathname] = uigetfile( ...
	{'*.mat', 'All MAT-Files (*.mat)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A GHRR COASTLINE FILE');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
  return
% Otherwise construct the fullfilename and Check and load the file.
else
  handles.coastfile = fullfile(pathname,filename);
  guidata(h,handles)
  inplot_Callback(h, eventdata, handles, varargin)
end
% ------------------------------------------------------------
% Callback for Open Townfile
% ------------------------------------------------------------
function varargout = townfile_callback(h, eventdata, handles, varargin)
% Use UIGETFILE to allow for the selection of a custom address book.
[filename, pathname] = uigetfile( ...
	{'*.dat', 'All MAT-Files (*.dat)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A ASCII TOWN FILE');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
  return
% Otherwise construct the fullfilename and Check and load the file.
else
  handles.townfile = fullfile(pathname,filename);
  guidata(h,handles)
  inplot_Callback(h, eventdata, handles, varargin)
end
% ------------------------------------------------------------
% Callback for Open History file
% ------------------------------------------------------------
function varargout = hisfile_callback(h, eventdata, handles, varargin)
% Use UIGETFILE to allow for the selection of a custom address book.

[filename, pathname] = uigetfile( ...
	{'*.nc', 'All netcdf-Files (*.nc)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A ROMS HISTORY NETCDF FILE');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
  return
% Otherwise construct the fullfilename and Check and load the file.
else
  handles=reset_handles(h,handles);
  handles.hisfile = fullfile(pathname,filename);
  nc=netcdf(handles.hisfile,'nowrite');
  if isempty(nc)
     disp('Warning : this is not a netcdf file !!!')
     handles.hisfile='';
     return
  else
    pm=nc{'pm'};
    if isempty(pm)
      close(nc)
      guidata(h,handles)
      gridfile_callback(h, eventdata, handles, varargin)
      return
    end
    close(nc)
    guidata(h,handles)
    handles=update_listbox(h, eventdata, handles, varargin);
  end
end
% ------------------------------------------------------------
% Callback for Open Grid file
% ------------------------------------------------------------
function varargout = gridfile_callback(h, eventdata, handles, varargin)
% Use UIGETFILE to allow for the selection of a custom address book.
[filename, pathname] = uigetfile( ...
	{'*.nc', 'All netcdf-Files (*.nc)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A ROMS GRID NETCDF FILE');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
  return
% Otherwise construct the fullfilename and Check and load the file.
else
  handles.gridfile = fullfile(pathname,filename);
  nc=netcdf(handles.gridfile,'nowrite');
  if isempty(nc)
     disp('Warning : this is not a netcdf file !!!')
     handles.gridfile='';
     return
  else
    close(nc)
    guidata(h,handles)
    handles=update_listbox(h, eventdata, handles, varargin);
  end
end
% --------------------------------------------------------------------
% Callback for update button
% --------------------------------------------------------------------
function varargout = update_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton1.
handles=update_listbox(h, eventdata, handles, varargin);
guidata(h,handles)
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% Update the variable list box
% --------------------------------------------------------------------
function handles = update_listbox(h, eventdata, handles, varargin)
% Updates the listbox to show the printable variables
vname2=[];
index_selected=[];
hisfile=handles.hisfile;
nc=netcdf(hisfile,'nowrite');
Vars = var(nc);
Varnames = [ncnames(Vars)];
nvar=length(Vars);
ndims=0*(1:nvar);
myindex=0;
lwrd=length(handles.vname);
for i=1:nvar
  vname=char(Varnames(i));
  myvar=nc{vname};
  ndims(i)=length(dim(myvar));
  if ndims(i)>2
    if isempty(vname2)
      vname2=vname;
    end
    myindex=myindex+1;
    if length(vname)==lwrd
      if vname==handles.vname
        index_selected=myindex;
      end
    end
  end
end
if isempty(index_selected)
  disp([handles.vname,' not found...'])
  index_selected=1;
  handles.vname=vname2;
  if isempty(handles.vname)
    error('No variable with a least 2 dimensions found')
  end
end
handles.colmin=[];
handles.colmax=[];
set(handles.editcolmin,'String',num2str(handles.colmin))
set(handles.editcolmax,'String',num2str(handles.colmax))
handles.units=nc{handles.vname}.units(:);
set(handles.editunits,'String',num2str(handles.units))
handles.longname=nc{handles.vname}.long_name(:);
set(handles.editlongname,'String',num2str(handles.longname))
handles.coef=1;
set(handles.editcoef,'String',num2str(handles.coef))
set(handles.listvar,'String',Varnames(ndims>2));
set(handles.listvar,'Value',index_selected)
close(nc)

if isempty(handles.gridfile)
  handles.gridfile=handles.hisfile;
end
nc=netcdf(handles.hisfile,'nowrite');
handles.N=length(nc('s_rho'));
handles.T=length(nc('time'));
if handles.T==0
  disp('Warning no time dimension found.. looking for tclm_time')
  handles.T=length(nc('tclm_time'));
end
if handles.T==0
  error('Warning no time dimension found')
end
close(nc)
nc=netcdf(handles.gridfile,'nowrite');
handles.L=length(nc('xi_rho'));
handles.M=length(nc('eta_rho'));
handles.hmax=max(max((nc{'h'}(:))));
lat=rempoints(nc{'lat_rho'}(:),handles.rempts);
lon=rempoints(nc{'lon_rho'}(:),handles.rempts);
handles.lonmin=min(min(lon));
handles.lonmax=max(max(lon));
handles.latmin=min(min(lat));   
handles.latmax=max(max(lat));
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
close(nc)
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% Callback for variable listbox
% --------------------------------------------------------------------
function varargout = listvar_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.listvar.
list_entries = get(handles.listvar,'String');
index_selected = get(handles.listvar,'Value');
if length(index_selected) ~= 1
	errordlg('You must select 1 variables','Incorrect Selection','modal')
else
  varname = list_entries{index_selected(1)};
  handles.vname=varname;
  handles.colmin=[];
  set(handles.editcolmin,'String',num2str(handles.colmin));
  handles.colmax=[];
  set(handles.editcolmax,'String',num2str(handles.colmax));
  nc=netcdf(handles.hisfile,'nowrite');
  handles.units=nc{handles.vname}.units(:);
  set(handles.editunits,'String',num2str(handles.units))
  handles.longname=nc{handles.vname}.long_name(:);
  set(handles.editlongname,'String',num2str(handles.longname))
  close(nc)
  handles.coef=1;
  set(handles.editcoef,'String',num2str(handles.coef))
  guidata(h,handles)
  inplot_Callback(h, eventdata, handles, varargin)
end 
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% Callback for derived variable listbox
% --------------------------------------------------------------------
function varargout = listdvar_Callback(h, eventdata, handles, varargin)
list_entries = get(handles.listdvar,'String');
index_selected = get(handles.listdvar,'Value');
if length(index_selected) ~= 1
	errordlg('You must select 1 variables','Incorrect Selection','modal')
else
  varname = list_entries{index_selected(1)};
  if ~isempty(varname)
    handles.vname=varname;
    handles.colmin=[];
    set(handles.editcolmin,'String',num2str(handles.colmin));
    handles.colmax=[];
    set(handles.editcolmax,'String',num2str(handles.colmax));
    handles.units='';
    set(handles.editunits,'String',num2str(handles.units))
    handles.longname='';
    set(handles.editlongname,'String',num2str(handles.vname))
    handles.coef=1;
    set(handles.editcoef,'String',num2str(handles.coef))
    guidata(h,handles)
    inplot_Callback(h, eventdata, handles, varargin)
  end 
end 
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% vertical levels
% --------------------------------------------------------------------
function varargout = upvlevel_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up vertical level'
if handles.vlevel < 0.
   handles.vlevel=handles.vlevel+100;
   if handles.vlevel >= 0.
     handles.vlevel=handles.N;
   end
else
   handles.vlevel=handles.vlevel + 1;
   if handles.vlevel >= handles.N
     handles.vlevel=handles.N;
   end
end
set(handles.editvlev,'String',num2str(handles.vlevel))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downvlevel_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down vertical level'
if handles.vlevel < 1
   handles.vlevel=handles.vlevel-100;
   if handles.vlevel <= -handles.hmax
     handles.vlevel=round(100-handles.hmax);
   end
else
   handles.vlevel=handles.vlevel - 1;
   if handles.vlevel < 1 
     handles.vlevel=handles.vlevel-100;
     if handles.vlevel <= 100-handles.hmax
       handles.vlevel=round(100-handles.hmax);
     end
   end
end
set(handles.editvlev,'String',num2str(handles.vlevel))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editvlev_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the vlevel text box
handles.vlevel = str2num(get(handles.editvlev,'String'));
if handles.vlevel >= handles.N
  handles.vlevel=handles.N;
  set(handles.editvlev,'String',num2str(handles.vlevel))
end
if handles.vlevel <= 100-handles.hmax
  handles.vlevel=round(100-handles.hmax);
  set(handles.editvlev,'String',num2str(handles.vlevel))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% end vertical levels
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% plot style
% --------------------------------------------------------------------
function varargout = pcolor_Callback(h, eventdata, handles, varargin)
handles.pltstyle=1;
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = contourf_Callback(h, eventdata, handles, varargin)
handles.pltstyle=2;
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = contour_Callback(h, eventdata, handles, varargin)
handles.pltstyle=3;
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = graycontour_Callback(h, eventdata, handles, varargin)
handles.pltstyle=4;
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = seawifs_Callback(h, eventdata, handles, varargin)
handles.pltstyle=5;
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% end plot style
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% lon min
% --------------------------------------------------------------------
function varargout = uplonmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up longitude minimum'
handles.lonmin=handles.lonmin + 1;
if handles.lonmin >= handles.lonmax
  handles.lonmin=handles.lonmax-0.01;
end
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downlonmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down longitude minimum'
handles.lonmin=handles.lonmin - 1;
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editlonmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the lonmin text box
handles.lonmin = str2num(get(handles.editlonmin,'String'));
if handles.lonmin >= handles.lonmax
  handles.lonmin=handles.lonmax-0.01;
  set(handles.editlonmin,'String',num2str(handles.lonmin))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end lon min
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% lon max
% --------------------------------------------------------------------
function varargout = uplonmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up longitude maximum'
handles.lonmax=handles.lonmax + 1;
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downlonmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down longitude maximum'
handles.lonmax=handles.lonmax - 1;
if handles.lonmax <= handles.lonmin
  handles.lonmax=handles.lonmin+0.01;
end
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editlonmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the lonmax text box
handles.lonmax = str2num(get(handles.editlonmax,'String'));
if handles.lonmax <= handles.lonmin
  handles.lonmax=handles.lonmax+0.01;
  set(handles.editlonmax,'String',num2str(handles.lonmax))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end lon max
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% lat min
% --------------------------------------------------------------------
function varargout = uplatmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up latitude minimum'
handles.latmin=handles.latmin + 1;
if handles.latmin >= handles.latmax
  handles.latmin=handles.latmax-0.01;
end
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downlatmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down latitude minimum'
handles.latmin=handles.latmin - 1;
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editlatmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the latmin text box
handles.latmin = str2num(get(handles.editlatmin,'String'));
if handles.latmin >= handles.latmax
  handles.latmin=handles.latmax-0.01;
  set(handles.editlatmin,'String',num2str(handles.latmin))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end lat min
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% lat max
% --------------------------------------------------------------------
function varargout = uplatmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up latitude maximum'
handles.latmax=handles.latmax + 1;
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downlatmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down latitude maximum'
handles.latmax=handles.latmax - 1;
if handles.latmax <= handles.latmin
  handles.latmax=handles.latmin+0.01;
end
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editlatmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the latmax text box
handles.latmax = str2num(get(handles.editlatmax,'String'));
if handles.latmax <= handles.latmin
  handles.latmax=handles.latmax+0.01;
  set(handles.editlatmax,'String',num2str(handles.latmax))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end lat max
% --------------------------------------------------------------------
% --------------------------------------------------------------------
%  zoom in
% --------------------------------------------------------------------
function varargout = zoom_in_Callback(h, eventdata, handles, varargin)
handles.latmin=handles.latmin + 1;
handles.latmax=handles.latmax - 1;
handles.lonmin=handles.lonmin + 1;
handles.lonmax=handles.lonmax - 1;
if handles.lonmax <= handles.lonmin
  handles.lonmax=handles.lonmax+1;
  handles.lonmin=handles.lonmin-1;
end
if handles.latmax <= handles.latmin
  handles.latmax=handles.latmax+1;
  handles.latmin=handles.latmin-1;
end
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end zoom in
% --------------------------------------------------------------------
% --------------------------------------------------------------------
%  zoom out
% --------------------------------------------------------------------
function varargout = zoom_out_Callback(h, eventdata, handles, varargin)
handles.latmin=handles.latmin - 1;
handles.latmax=handles.latmax + 1;
handles.lonmin=handles.lonmin - 1;
handles.lonmax=handles.lonmax + 1;
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end zoom out
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% tindex
% --------------------------------------------------------------------
function varargout = uptindex_Callback(h, eventdata, handles, varargin)
handles.tindex=handles.tindex + 1;
if handles.tindex >= handles.T
  handles.tindex=handles.T;
end
set(handles.edittindex,'String',num2str(handles.tindex))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downtindex_Callback(h, eventdata, handles, varargin)
handles.tindex=handles.tindex - 1;
if handles.tindex <= 1
  handles.tindex=1;
end
set(handles.edittindex,'String',num2str(handles.tindex))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edittindex_Callback(h, eventdata, handles, varargin)
handles.tindex = floor(str2num(get(handles.edittindex,'String')));
if handles.tindex <= 1
  handles.tindex=1;
  set(handles.edittindex,'String',num2str(handles.tindex))
end
if handles.tindex >= handles.T
  handles.tindex=handles.T;
  set(handles.edittindex,'String',num2str(handles.tindex))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end tindex
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% cstep
% --------------------------------------------------------------------
function varargout = upcstep_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up cstep'
handles.cstep=handles.cstep + 1;
set(handles.editcstep,'String',num2str(handles.cstep))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downcstep_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down cstep'
handles.cstep=handles.cstep - 1;
if handles.cstep <= 0
  handles.cstep=0;
end
set(handles.editcstep,'String',num2str(handles.cstep))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editcstep_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the cstep text box
handles.cstep = floor(str2num(get(handles.editcstep,'String')));
if handles.cstep <= 0
  handles.cstep=0;
  set(handles.editcstep,'String',num2str(handles.cstep))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end cstep
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% cscale
% --------------------------------------------------------------------
function varargout = slidercscale_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the cscale slider
handles.cscale = 20*get(handles.slidercscale,'Value');
set(handles.editcscale,'String',num2str(handles.cscale,2))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editcscale_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the cscale text box
handles.cscale = str2num(get(handles.editcscale,'String'));
if handles.cscale <= 0.01
  handles.cscale=0.01;
  set(handles.editcscale,'String',num2str(handles.cscale))
end
if handles.cscale >= 20
  handles.cscale=20;
  set(handles.editcscale,'String',num2str(handles.cscale))
end
set(handles.slidercscale,'Value',handles.cscale/20)
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% end cscale
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% cunit
% --------------------------------------------------------------------
function varargout = upcunit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up cunit'
handles.cunit=handles.cunit + 0.01;
set(handles.editcunit,'String',num2str(handles.cunit))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downcunit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down cunit'
handles.cunit=handles.cunit - 0.01;
if handles.cunit <= 0.01
  handles.cunit=0.01;
end
set(handles.editcunit,'String',num2str(handles.cunit))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editcunit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the cunit text box
handles.cunit = str2num(get(handles.editcunit,'String'));

if handles.cunit < 0.01
  handles.cunit=0.01;
  set(handles.editcunit,'String',num2str(handles.cunit))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end cunit
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ncol
% --------------------------------------------------------------------
function varargout = upncol_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'up ncol'
handles.ncol=handles.ncol + 1;
set(handles.editncol,'String',num2str(handles.ncol))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = downncol_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the pushbutton 'down ncol'
handles.ncol=handles.ncol - 1;
if handles.ncol <= 2
  handles.ncol=2;
end
set(handles.editncol,'String',num2str(handles.ncol))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editncol_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the ncol text box
handles.ncol = floor(str2num(get(handles.editncol,'String')));
if handles.ncol <= 2
  handles.ncol=2;
  set(handles.editncol,'String',num2str(handles.ncol))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end ncol
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  colmin
% --------------------------------------------------------------------
function varargout = editcolmin_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the ncol text box
handles.colmin = str2num(get(handles.editcolmin,'String'));
if handles.colmin >= handles.colmax
  handles.colmin=handles.colmax-0.01;
  set(handles.editcolmin,'String',num2str(handles.colmin))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end colmin
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  colmax
% --------------------------------------------------------------------
function varargout = editcolmax_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the ncol text box
handles.colmax = str2num(get(handles.editcolmax,'String'));
if handles.colmax <= handles.colmin
  handles.colmax=handles.colmin+0.01;
  set(handles.editcolmax,'String',num2str(handles.colmax))
end
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end colmax
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  resetcolors
% --------------------------------------------------------------------
function varargout = resetcolors_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton25.
handles.colmax = [];
handles.colmin = [];
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end resetcolors
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  boundary points
% --------------------------------------------------------------------
function varargout = editnptsW_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.editnptsW.
handles.rempts(1)=floor(min([((handles.L-4)/2)  ...
                         abs(str2num(get(handles.editnptsW,'String')))]));
set(handles.editnptsW,'String',num2str(handles.rempts(1)))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editnptsE_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.editnptsE.
handles.rempts(2)=floor(min([((handles.L-4)/2)  ...
                         abs(str2num(get(handles.editnptsE,'String')))]));
set(handles.editnptsE,'String',num2str(handles.rempts(2)))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editnptsS_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.editnptsS.
handles.rempts(3)=floor(min([((handles.M-4)/2)  ...
                         abs(str2num(get(handles.editnptsS,'String')))]));
set(handles.editnptsS,'String',num2str(handles.rempts(3)))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = editnptsN_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.editnptsN.
handles.rempts(4)=floor(min([((handles.M-4)/2)  ...
                         abs(str2num(get(handles.editnptsN,'String')))]));
set(handles.editnptsN,'String',num2str(handles.rempts(4)))
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end boundary points
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  isobath
% --------------------------------------------------------------------
function varargout = editisobath_Callback(h, eventdata, handles, varargin)
handles.isobath=get(handles.editisobath,'String');
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end isobath
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  coeff
% --------------------------------------------------------------------
function varargout = editcoef_Callback(h, eventdata, handles, varargin)
handles.coef=str2num(get(handles.editcoef,'String'));
guidata(h,handles)
resetcolors_Callback(h, eventdata, handles, varargin);
% --------------------------------------------------------------------
%  end coeff
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%  Number of embedded levels
% --------------------------------------------------------------------
function varargout = editnlev_Callback(h, eventdata, handles, varargin)
handles.gridlevs=str2num(get(handles.editnlev,'String'));
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%  end number of embedded levels
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% --------------------------------------------------------------------
%  Do a plot in the GUI
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = inplot_Callback(h, eventdata, handles, varargin)
horizslice(handles.hisfile,handles.vname,handles.tindex,...
           handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
	   handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
           handles.latmin,handles.latmax,handles.ncol,...
           handles.pltstyle,handles.isobath,handles.cstep,...
           handles.cscale,handles.cunit,handles.coastfile,...
           handles.townfile,handles.gridfile,h,handles)
% --------------------------------------------------------------------
% --------------------------------------------------------------------
%  Do a plot outside of the GUI
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = outplot_Callback(h, eventdata, handles, varargin)
figure(1)
horizslice(handles.hisfile,handles.vname,handles.tindex,...
           handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
	   handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
           handles.latmin,handles.latmax,handles.ncol,...
           handles.pltstyle,handles.isobath,handles.cstep,...
           handles.cscale,handles.cunit,handles.coastfile,...
           handles.townfile,handles.gridfile,[],[])
% --------------------------------------------------------------------
% --------------------------------------------------------------------
%  Print
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = print_Callback(h, eventdata, handles, varargin)
outplot_Callback(h, eventdata, handles, varargin)
[day,month,year,thedate]=...
get_date(handles.hisfile,handles.tindex);
if handles.vname(1)=='*'
  fname=[handles.vname(2:3),...
         num2str(day),month,num2str(year),...
         '_z',num2str(handles.vlevel),'.eps'];
else
  fname=[handles.vname,num2str(day),month,num2str(year),...
         '_z',num2str(handles.vlevel),'.eps'];
end
disp(['EPS file : ',fname])
eval(['print -painter -depsc2 ',fname])

% --------------------------------------------------------------------
% --------------------------------------------------------------------
%    Vertical section
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = vsection_Callback(h, eventdata, handles, varargin)
[lon1,lat1,lon2,lat2]=get_mouse(handles);
figure(1)
vertslice(handles.hisfile,handles.gridfile,[lon1 lon2],[lat1 lat2],...
          handles.vname,handles.tindex,handles.coef,[],[],...
	  handles.ncol,[],[],[],[],handles.pltstyle,[],[])
% --------------------------------------------------------------------
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% --------------------------------------------------------------------
%    Hovmuller diagram
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = hovmull_Callback(h, eventdata, handles, varargin)
[lon1,lat1,lon2,lat2]=get_mouse(handles);
figure(1)
hovmuller(handles.hisfile,handles.gridfile,[lon1 lon2],[lat1 lat2],...
          handles.vname,[1:handles.T],handles.vlevel,handles.coef,...
          [],[],handles.ncol,[],[],[],[],handles.pltstyle)
% --------------------------------------------------------------------
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function handles = reset_handles(h,handles)
handles.hisfile='';
handles.gridfile='';
handles.L=[];
handles.M=[];
handles.N=[];
handles.T=[];
handles.hmax=[];
handles.ng=[];
handles.coastfile=[];
handles.vname='zeta';
handles.vlevel=-10;
handles.pltstyle=1;
handles.lonmin=-99;
handles.tindex=1;
handles.lonmax=99;
handles.latmin=-99;
handles.latmax=99;
handles.cstep=0;
handles.cscale=1;
handles.cunit=0.1;
handles.colmin=[];
handles.colmax=[];
handles.ncol=10;
handles.coef=1;
handles.gridlevs=0;
handles.day=[];
handles.month=[];
handles.year=[];
handles.thedate='';
handles.rempts=[1 1 1 1];
handles.units='';
handles.longname='';
handles.townfile=[];
handles.isobath='100 500';
handles.skipanim=1;
set(handles.slidercscale,'Value',handles.cscale/20);
set(handles.editcoef,'String',num2str(handles.coef))
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
%%%
%%% a continuer !!!
%%%
guidata(h,handles)

% --------------------------------------------------------------------
function varargout = remcoast_Callback(h, eventdata, handles, varargin)
handles.coastfile=[];
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = remtowns_Callback(h, eventdata, handles, varargin)
handles.townfile=[];
guidata(h,handles)
inplot_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% ------------------------------------------------------------
% Callback for the Close button
% ------------------------------------------------------------
function varargout = close_Callback(h, eventdata, handles, varargin)
Answer=questdlg('Are you sure you want to close ?', ...
        '-CLOSE-', ...
        'Yes','No','Yes');
switch Answer
case {'No'}
case 'Yes'
  delete(handles.figure1)
end
% --------------------------------------------------------------------
% --------------------------------------------------------------------
% ---------------------------   fin   --------------------------------
% --------------------------------------------------------------------
% --------------------------------------------------------------------




% --------------------------------------------------------------------
function varargout = animation_Callback(h, eventdata, handles, varargin)
animation(handles)
% --------------------------------------------------------------------
function varargout = editskipanim_Callback(h, eventdata, handles, varargin)
handles.skipanim=floor(abs(str2num(get(handles.editskipanim,'String'))));
set(handles.editskipanim,'String',num2str(handles.skipanim))
guidata(h,handles)
