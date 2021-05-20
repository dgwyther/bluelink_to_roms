function interpvar3d(np,nc,igrid_par,jgrid_par,...
                   igrid_child,jgrid_child,...
                   varname,mask,tindex)
%
%  Interpole a 3D variable on a nested grid
%
% Pierrick Penven 2004
%
imin=min(min(igrid_par));
imax=max(max(igrid_par));
jmin=min(min(jgrid_par));
jmax=max(max(jgrid_par));
%
if ~isempty(mask)
  [I,J]=meshgrid(imin:imax,jmin:jmax);
  if varname(1)=='u'
    mask=mask(:,1:end-1).*mask(:,2:end);
  elseif varname(1)=='v'
    mask=mask(1:end-1,:).*mask(2:end,:);
  end
  mask=mask(jmin:jmax,imin:imax);
end
var_par=squeeze(np{varname}(tindex,jmin:jmax,imin:imax));
if ~isempty(mask)
  var_par(mask==0)=griddata(I(mask==1),J(mask==1),var_par(mask==1),...
                            I(mask==0),J(mask==0),'nearest');
end
nc{varname}(tindex,:,:)=interp2(igrid_par,jgrid_par,var_par,...
                                igrid_child,jgrid_child,'cubic');
return
