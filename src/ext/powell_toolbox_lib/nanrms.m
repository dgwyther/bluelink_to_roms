function x = nanrms(x, dim)

% NANRMS   COMPUTE RMS OF X WHILE IGNORING NaN VALUES
%
% Compute the RMS of variable x; however, each NaN value present is
% treated as an empty value.
% 
% SYNTAX
%   X = NANRMS(X, DIM)
% 
% 2007, Brian Powell

error(nargchk(1, 2, nargin));
if ( nargin < 2 )
  dim = 1;
end

% If it is a single row vector, then transpose it
if ( isrowvector(x) )
  x = x';
end

% Check for scalar
if ( isscalar(x) ) return; end

% count the non nan's in the dimension
c = ~isnan(x);
len = sum(c,dim);

% protect against all nan
len(find(~len))=nan;

% flip the nans to zero
x(find(isnan(x))) = 0;
x = sqrt( sum(x.^2,dim) ./ len );
