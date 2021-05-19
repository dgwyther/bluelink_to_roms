function x = nanmax(x, y)

% NANMAX   COMPUTE MAX OF X WHILE IGNORING NaN VALUES
%
% Compute the maximum of variable x and y; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANMAX(X, Y)
% 
% 2007, Brian Powell

% max does the job just fine
if ( nargin < 2)
  x = max(x);
else
  x = max(x,y);
end
