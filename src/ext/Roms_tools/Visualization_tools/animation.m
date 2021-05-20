function animation(handles)
%
% pierrick 2001
%
% Create an animation from a ROMS netcdf file
%
% Switch to enable fli animations and/or mpeg animations 
%
anim_mpeg=1;
anim_fli=1;
%
%
%
moviename=[handles.vname,'_z',num2str(handles.vlevel),'.fli'];
%
% Initialise the animation 
%
fid = fli_begin;
fr = 0;
plot_index=0;
nc=netcdf(handles.hisfile);
ntime=length(nc('time'));
if ntime==0
  disp('Warning no time dimension found.. looking for tclm_time')
  ntime=length(nc('tclm_time'));
end
if ntime==0
  error('Warning no time dimension found')
end
close(nc)
%
% loop on the time 
%
for tindex=1:ntime
  plot_index=plot_index+1;
  if mod(plot_index,handles.skipanim)==0
    fr = fr + 1;
    figure(1)
    horizslice(handles.hisfile,handles.vname,plot_index,...
           handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
	   handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
           handles.latmin,handles.latmax,handles.ncol,...
           handles.pltstyle,handles.isobath,handles.cstep,...
           handles.cscale,handles.cunit,handles.coastfile,...
           handles.townfile,handles.gridfile,[],[])
    getframe_fli(fr,fid)
  end
end
if anim_mpeg==1
  eval(['!ppmtompeg ../Visualization_tools/inp_ppm2mpeg'])
  eval(['!mv movie.mpg ',handles.vname,'_z',num2str(handles.vlevel),'.mpg']);
end
if anim_fli==1
  fli_end(fid,moviename);
else
  eval(['!rm -f ','.ppm.list'])
end
