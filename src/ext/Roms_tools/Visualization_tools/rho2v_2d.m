function var_v=rho2v_2d(var_rho);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var_v=rho2v_2d(var_rho);
%
% interpole a field at rho points to a field at v points
%
% input:
%
%  var_rho variable at rho-points (2D matrix)
%
% output:
%
%  var_v   variable at v-points (2D matrix)  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(var_rho);
M=Mp-1;
var_v=0.5*(var_rho(1:M,:)+var_rho(2:Mp,:));
return

