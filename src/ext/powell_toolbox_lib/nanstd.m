function x = nanstd(x, dim)

% NANSTD   COMPUTE STD OF X WHILE IGNORING NaN VALUES
%
% Compute the std of variable x; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANSTD(X, DIM)
% 
% 2007, Brian Powell

error(nargchk(1, 2, nargin));
if ( nargin < 2 )
  dim = 1;
end

% Check for scalar
if ( isscalar(x) ) 
  x=0; 
  return; 
end
  
% If it is a single row vector, then transpose it
if ( isrow(x) )
  x = x';
end

% First get the mean
s = ones(1,ndims(x));
m = nanmean(x,dim);
s(dim) = size(x,dim);
m = repmat(m,s);

% deviations
d = (x - m).^2;

% count the non nan's in the dimension
c = ~isnan(d);
len = sum(c,dim) - 1;
len(find(len<=0))=nan;

% flip the nans to zero
d(find(isnan(d))) = 0;
x = sqrt(sum(d,dim) ./ len);

