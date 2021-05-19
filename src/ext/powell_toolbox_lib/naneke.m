function eke = naneke(u)

% function eke = naneke(u, v)
%
% Given u and v vectors, compute the EKE

% Reshape the data into column vector
[n,m]=size(u);
if ( m~=1 )
  u=reshape(u,n*m,1);
end
u=rmnan(u);
n=size(u,1);

% EKE is just the raw second moment
eke = sum(u.^2)./n;
