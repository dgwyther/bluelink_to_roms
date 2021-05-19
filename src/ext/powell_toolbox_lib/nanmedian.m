function x = nanmedian(x, dim)

% NANMEDIAN   COMPUTE MEDIAN OF X WHILE IGNORING NaN VALUES
%
% Compute the median of variable x; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANMEDIAN(X, DIM)
% 
% 2007, Brian Powell

error(nargchk(1, 2, nargin));
if ( nargin < 2 )
  dim = 1;
end

if (ndims(x)>2)
  error('needs modifications for larger dimensions')
end

% put in order
d = [1:ndims(x)];
d(1) = dim;
d(dim) = 1;
s = sort(x,dim);
len = sum(~isnan(s),dim);
odd = find(isodd(len));
even = find(iseven(len));

% set up the results
sz = size(x);
sz(dim)=1;
x = ones(sz)*nan;

% shift the matrix
s = permute(s,d);
if ( isempty(s) ) return; end
sz = size(s);
mid = vector(round((len+1) / 2));
count = vector(linspace(1,length(mid),length(mid)));

% Handle the odd elements first (the easiest)
if ( ~isempty(odd) )
  x(odd) = s(sub2ind(sz,mid(odd),count(odd)));
end

if ( ~isempty(even) )
  x(even) = (s(sub2ind(sz,mid(even),count(even))) + ...
             s(sub2ind(sz,mid(even)-1,count(even)))) / 2;
end

