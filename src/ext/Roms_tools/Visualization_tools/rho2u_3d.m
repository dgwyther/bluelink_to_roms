function var_u=rho2u_3d(var_rho);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
% function var_u=rho2u_3d(var_rho);
%
% interpole a field at rho points to a field at u points
%
% input:
%
%  var_rho variable at rho-points (3D matrix)
%
% output:
%
%  var_u   variable at u-points (3D matrix)  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[N,Mp,Lp]=size(var_rho);
L=Lp-1;
var_u=0.5*(var_rho(:,:,1:L)+var_rho(:,:,2:Lp));
return

