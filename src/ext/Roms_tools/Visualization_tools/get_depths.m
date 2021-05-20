function z=get_depths(fname,gname,tindex,type);
%
% Get the depths of the sigma levels
%
% open grid (or history) file
%
nc=netcdf(gname);
h=nc{'h'}(:);
close(nc);
%
% open history file
%
nc=netcdf(fname);
zeta=squeeze(nc{'zeta'}(tindex,:,:));
theta_s=nc.theta_s(:);
if (isempty(theta_s))
%  disp('Rutgers version')
  theta_s=nc{'theta_s'}(:);
  theta_b=nc{'theta_b'}(:);
  Tcline=nc{'Tcline'}(:);
else 
%  disp('UCLA version');
  theta_b=nc.theta_b(:);
  Tcline=nc.Tcline(:);
end
if (isempty(Tcline))
%  disp('UCLA version 2');
  hc=nc.hc(:);
else
  hmin=min(min(h));
  hc=min(hmin,Tcline);
end 
N=length(nc('s_rho'));
close(nc)
%
%
%
if isempty(zeta)
  zeta=0.*h;
end

vtype=type;
if (type=='u')|(type=='v')
  vtype='r';
end
z=zlevs(h,zeta,theta_s,theta_b,hc,N,vtype);
if type=='u'
  z=rho2u_3d(z);
end
if type=='v'
  z=rho2v_3d(z);
end
return
