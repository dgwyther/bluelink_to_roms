function siz = sizes(x, dims)
%SIZES  Sizes of a matrix or array.
%
%   S = SIZES(X, DIMS), returns a vector with the sizes of X along the
%   dimensions specified in DIMS.  That is, S(I) = SIZE(X, DIMS(I)) for all
%   I = 1...LENGTH(DIMS).
%
%   See also SIZE, LENGTH, NDIMS.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:23:22 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   nargsin = nargin;
   error(nargchk(1, 2, nargsin));

   sd = size(dims);
   if sum(size(dims) > 1) > 1 | any(dims < 1)
      error('DIMS must be a vector of positive integers.');
   end
   dims = fix(dims);         % make sure values are integers

   sx = size(x);
   dx = ndims(x);

   k = dims <= dx;
   siz = ones(sd);
   siz(k) = sx(dims(k));
