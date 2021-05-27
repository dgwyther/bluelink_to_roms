function y = flipdim(x, dim)
%FLIPDIM Flip matrix along specified dimension.
%
%   FLIPDIM(X,DIM) returns X with dimension DIM flipped and all other
%   dimensions preserved.  For example, FLIPDIM(X,1) where
%
%     X(:,:,1) =  1   2   3     X(:,:,2) =  7   8   9
%                 4   5   6                10  11  12
%
%   produces
%
%     X(:,:,1) =  3   2   1     X(:,:,2) =  9   8   7
%                 6   5   4                12  11  10
%
%   See also FLIPLR, FLIPUD, ROT90, PERMUTE.

   error(nargchk(2, 2, nargin));

   n = size(x, dim);
   if n <= 1
      y = x;
   else
      idx{ndims(x)} = ':';
      idx(:) = idx(end);
      idx{dim} = n:-1:1;
      y = x(idx{:});
   end
