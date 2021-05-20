function [ufield,vfield,pfield]=rho2uvp(rfield);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2002 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%   compute the values at u,v and psi points...                   %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(rfield);
M=Mp-1;
L=Lp-1;
%
vfield=0.5*(rfield(1:M,:)+rfield(2:Mp,:));
ufield=0.5*(rfield(:,1:L)+rfield(:,2:Lp));
pfield=0.5*(ufield(1:M,:)+ufield(2:Mp,:));
return













