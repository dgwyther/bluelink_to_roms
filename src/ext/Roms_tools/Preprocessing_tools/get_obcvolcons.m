function [u,v]=get_obcvolcons(u,v,pm,pn,rmask,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Enforce integral flux conservation around the domain
%
%  penven 23-10-2001
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
umask=rmask(1:end,2:end).*rmask(1:end,1:end-1);
vmask=rmask(2:end,1:end).*rmask(1:end-1,1:end);
%
dy_u=2*umask./(pn(1:end,2:end)+pn(1:end,1:end-1));
dx_v=2*vmask./(pm(2:end,1:end)+pm(1:end-1,1:end));
udy=u.*dy_u;
vdx=v.*dx_v;
%
Flux=obc(1)*sum(vdx(1,2:end-1))-obc(2)*sum(udy(2:end-1,end))-...
     obc(3)*sum(vdx(end,2:end-1))+obc(4)*sum(udy(2:end-1,1));
Cross=obc(1)*sum(dx_v(1,2:end-1))+obc(2)*sum(dy_u(2:end-1,end))+...
      obc(3)*sum(dx_v(end,2:end-1))+obc(4)*sum(dy_u(2:end-1,1));
vcorr=Flux/Cross;
disp(['Flux correction : ',num2str(vcorr)])
%
v(1,:)=obc(1)*(v(1,:)-vcorr);
u(:,end)=obc(2)*(u(:,end)+vcorr);
v(end,:)=obc(3)*(v(end,:)+vcorr);
u(:,1)=obc(4)*(u(:,1)-vcorr);
%
u=u.*umask;
v=v.*vmask; 
%
return
