function x = nansum(x, dim)

% NANSUM   COMPUTE SUM OF X WHILE IGNORING NaN VALUES
%
% Compute the sum of variable x; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANSUM(X, DIM)
% 
% 2007, Brian Powell

error(nargchk(1, 2, nargin));
if ( nargin < 2 )
  dim = 1;
end

% If it is a single row vector, then use second dimension
if ( isrowvector(x) )
  dim = 2;
end

% count the non nan's in the dimension
c = ~isnan(x);
len = sum(c,dim);

% flip the nans to zero
x(find(isnan(x))) = 0;
x = sum(x,dim);

% protect against all nan
x(find(~len))=nan;

