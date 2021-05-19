function x = trimtails(x, tail)


% function trimtails(data, percent)
%
% This function removes the give percentage from the tails of the 
% distribution. If none is given, it removes 1% from each tail.
% NOTE: data is not actually removed, but NaN'ed out.

if ( nargin < 1 )
  error('you must specify data');
end
if ( nargin < 2 )
  tail = 1;
end

tail = tail / 100;
n = sort(x(:));
d = max( floor(length(n)*tail ), 1 );
l = [ n(1:d); n(end-d:end) ];
m = vecfind(x(:), l);
x(m) = nan;
