function x = nanvar(x, dim)

% NANVAR   COMPUTE VAR OF X WHILE IGNORING NaN VALUES
%
% Compute the var of variable x; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANVAR(X, DIM)
% 
% 2007, Brian Powell

error(nargchk(1, 2, nargin));
if ( nargin < 2 )
  dim = 1;
end

x=nanstd(x,dim).^2;
