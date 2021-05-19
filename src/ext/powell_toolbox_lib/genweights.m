function [cn, error] = genweights(p, q, dt)

% function [cn, error] = genweights(p, q, dt)
% Given p and q, return the vector of c_n's: the optimal weighting
% coefficients.  If dt is not specified, it defaults to 1s.
% p is the number of points before the point of interest (always negative)
% q is the number of points after the point of interest (always positive)
%
% Written by Brian Powell (c) 2004, University of Colorado at Boulder
if ( nargin < 2 )
  error('Incorrect Arguments');
elseif ( nargin < 3 )
  dt = 1;
end

% Do some verification
p = max(p,-p);
q = max(q,-q);
if ( -p > q )
  error('p must be less than q');
end

% Build the matrices
N = abs(p) + abs(q);
T = N + 1;
A = zeros(T,T);
A(T,:) = [ ones(1,N) 0 ];
n = [ -p:q ];
n = n(find(n~=0));
for i=1:length(n),
  A(i,:) = [ 1./n.*(-n(i)/2) n(i)^2*dt^2/4 ];
  A(i,i) = -1;
end
B = zeros(T,1);
B(end) = 1;

% Compute the coefficients
cn = A \ B;
cn = cn(1:end-1);

% Compute the error
error = sqrt( sum(cn'./(n*dt))^2 + sum( (cn'./(n*dt)).^2 ) );
