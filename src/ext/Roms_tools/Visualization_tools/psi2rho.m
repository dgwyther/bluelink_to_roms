function [var_rho]=psi2rho(var_psi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%   transfert a field at rho points to a field at psi points      %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(var_psi);
Mp=M+1;
Lp=L+1;
Mm=M-1;
Lm=L-1;
var_rho=zeros(Mp,Lp);
var_rho(2:M,2:L)=0.25*(var_psi(1:Mm,1:Lm)+var_psi(1:Mm,2:L)+...
                       var_psi(2:M,1:Lm)+var_psi(2:M,2:L));
var_rho(1,:)=var_rho(2,:);
var_rho(Mp,:)=var_rho(M,:);
var_rho(:,1)=var_rho(:,2);
var_rho(:,Lp)=var_rho(:,L);
return

