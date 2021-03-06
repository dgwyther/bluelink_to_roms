function [lambda2]=okubo_roms(u,v,pm,pn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Pierrick 2003                                                 %
%                                                                 %
%   compute the OkuboWeiss criterion                              %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(pm);
L=Lp-1;
M=Mp-1;
Lm=L-1;
Mm=M-1;
xi=zeros(M,L);
mn_p=zeros(M,L);
uom=zeros(M,Lp);
von=zeros(Mp,L);
uom=2*u./(pm(:,1:L)+pm(:,2:Lp));
uon=2*u./(pn(:,1:L)+pn(:,2:Lp));
von=2*v./(pn(1:M,:)+pn(2:Mp,:));
vom=2*v./(pm(1:M,:)+pm(2:Mp,:));
mn=pm.*pn;
mn_p=(mn(1:M,1:L)+mn(1:M,2:Lp)+...
      mn(2:Mp,2:Lp)+mn(2:Mp,1:L))/4;
%
% relative vorticity
%
xi=mn.*psi2rho(von(:,2:Lp)-von(:,1:L)-uom(2:Mp,:)+uom(1:M,:));
%
% Sigma_T
%
ST=mn.*psi2rho(von(:,2:Lp)-von(:,1:L)+uom(2:Mp,:)-uom(1:M,:));
%
% Sigma_N
%
SN=zeros(Mp,Lp);
SN(2:end-1,2:end-1)=mn(2:end-1,2:end-1).*(uon(2:end-1,2:end)...
                                         -uon(2:end-1,1:end-1)...
                                         -vom(2:end,2:end-1)...
                                         +vom(1:end-1,2:end-1));
%
% 
%
lambda2=SN.^2+ST.^2-xi.^2;
return

