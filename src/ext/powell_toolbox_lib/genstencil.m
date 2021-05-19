function [stencil, cn]=genstencil(d)

% Given a 

if ( nargin < 1 )
  error('You must provide an odd-numbered square distance matrix.');
end

T = (size(d,1)-1)/2;

if ( ~issquare(d) | ~isint(T) )
  error('You must provide an odd-numbered square distance matrix.');
end

% Construct the difference stencil
d(T+1,T+1) = 0;
cn = zeros(size(d));
stencil = d;
l=find(stencil~=0);
stencil(l) = 1 ./ stencil(l).^2;

% Construct the weighting stencil

% Set up the system of equations
l=find(d~=0);
len = length(l) + 1;
A=zeros(len,len);
B=zeros(len,1);

% The summation term
dpq = (1./d(l).^2)';

% The delta (distance terms)
dist = d(l).^2 ./ 2;

% Lambda column
A(1:len-1,len) = dist.^2;

% Resize, multiply and assign
dpq = dpq(ones(len-1,1),:);
dist = dist(:,ones(1,len-1));
A(1:len-1,1:len-1) = dpq .* -dist;
A(len,:) = ones(1,len);

% Set the diagonal
for i=[1:len-1],
  A(i,i) = -1;
end

% Set the last cell
A(len,len) = 0;
B(len) = len-1;

c = A \ B;
cn(l) = c(1:len-1);
stencil = stencil .* cn;
stencil(T+1,T+1) = -sum(sum(stencil));

