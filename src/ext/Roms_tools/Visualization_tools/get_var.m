function [lat,lon,mask,var]=get_var(hisfile,gridfile,vname,tindex,...
                                    vlevel,coef,rempts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2003
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Read data
%
if isempty(gridfile)
  gridfile=hisfile;
end
if vname(1)=='*'
  if vname(2:3)=='Ke'
    [lat,lon,mask,var]=get_ke(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:3)=='Vp'
    [lat,lon,mask,var]=get_pv(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Rho'
    [lat,lon,mask,var]=get_rho(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Vor'
    [lat,lon,mask,var]=get_vort(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Psi'
    [lat,lon,mask,var]=get_streamfunc(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Spd'
    [lat,lon,mask,var]=get_speed(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Svd'
    [lat,lon,mask,var]=get_transfunc(hisfile,gridfile,tindex,coef);
  elseif vname(2:4)=='Oku'
    [lat,lon,mask,var]=get_okubo(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Rpo'
    [lat,lon,mask,var]=get_pot(hisfile,gridfile,tindex,vlevel,coef);
  elseif vname(2:4)=='Bvf'
    [lat,lon,mask,var]=get_bvf(hisfile,gridfile,tindex,vlevel,coef);
  else 
    error('bad luck !')
  end 
else
  [type,vlev]=get_type(hisfile,vname,vlevel);
  [lat,lon,mask]=read_latlonmask(gridfile,type);
  var=coef*mask.*get_hslice(hisfile,gridfile,vname,...
  tindex,vlev,type);
end
%
% Remove boundary values
%
lat=rempoints(lat,rempts);
lon=rempoints(lon,rempts);
mask=rempoints(mask,rempts);
var=rempoints(var,rempts);
%
% End
%
return
