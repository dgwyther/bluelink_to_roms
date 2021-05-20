function var=get_hslice(fname,gname,vname,tindex,level,type);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
% function var=get_hslice(fname,vname,tindex,level,type);
%
% get an horizontal slice of a ROMS variable
%
% input:
%
%  fname    ROMS netcdf file name (average or history) (string)
%  gname    ROMS netcdf grid file name  (string)
%  vname    name of the variable (string)
%  tindex   time index (integer)
%  level    vertical level of the slice (scalar):
%             level =   integer >= 1 and <= N
%                       take a slice along a s level (N=top))
%             level =   0
%                       2D horizontal variable (like zeta)
%             level =   real < 0
%                       interpole a horizontal slice at z=level
%  type    type of the variable (character):
%             r for 'rho' for zeta, temp, salt, w(!)
%             w for 'w'   for AKt
%             u for 'u'   for u, ubar
%             v for 'v'   for v, vbar
%
% output:
%
%  var     horizontal slice (2D matrix)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(fname);
if level==0
%
% 2D variable
%
  var=squeeze(nc{vname}(tindex,:,:));
elseif level>0
%
% Get a sigma level of a 3D variable
%
  var=squeeze(nc{vname}(tindex,level,:,:));
else
%
% Get a horizontal level of a 3D variable
%
% Get the depths of the sigma levels
%
  z=get_depths(fname,gname,tindex,type);
%
% Read the 3d matrix and do the interpolation
%
  var_sigma=squeeze(nc{vname}(tindex,:,:,:));
  var = vinterp(var_sigma,z,level);
end
close(nc);
return
