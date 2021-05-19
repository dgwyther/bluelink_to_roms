function x = nanmin(x, y)

% NANMIN   COMPUTE MIN OF X WHILE IGNORING NaN VALUES
%
% Compute the minimium of variable x and y; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANMIN(X, Y)
% 
% 2007, Brian Powell

% min does the job just fine
if ( nargin < 2)
  x = min(x);
else
  x = min(x,y);
end
