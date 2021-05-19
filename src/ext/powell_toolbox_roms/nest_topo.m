function hchild = nest_topo(hchild,hparent,mask)

% Given a parent bathy and a child bathy, blend the borders as determined
% by the mask. The mask has values 0 for no blend, 1 for E/W blending, and
% 2 for N/S blending, 3 for combined
[Mp,Lp]=size(hchild);
alpha=0*hchild;

% North & South

% West & East
m=bitand(mask,1);
for i=1:Mp,
  % West
  fac=min(find(m(i,:)==0));
  if isempty(fac) fac=1; end
  alpha(i,1:fac)=max(alpha(i,1:fac),cos(pi/2*[1:fac]/fac));
  % East
  pts=find(m(i,:)==1);
  if ~isempty(pts)
    fac=pts(fac);
    alpha(i,fac:Lp)=max(alpha(i,fac:Lp),cos(pi/2*[Lp-fac+1:-1:1]/(Lp-fac+1)));
  end
end

% North & South
m=bitand(mask,2);
for i=1:Lp,
  % South
  fac=min(find(m(:,i)==0));
  if isempty(fac) fac=1; end
  alpha(1:fac,i)=max(alpha(1:fac,i),cos(pi/2*[1:fac]/fac)');
  % North
  pts=find(m(:,i)==2);
  if ~isempty(pts)
    fac=pts(fac);
    alpha(fac:Mp,i)=max(alpha(fac:Mp,i),cos(pi/2*[Mp-fac+1:-1:1]/(Mp-fac+1))');
  end
end
hchild = hparent.*alpha + (1-alpha).*hchild;
