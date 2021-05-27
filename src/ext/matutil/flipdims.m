function y = flipdims(x, dims)
%FLIPDIMS Flip array along specified dimensions.
%
%   FLIPDIMS(X, DIMS) flips the array X along all dimensions specified in
%   DIMS.  DIMS must be a vector of real values >= 1.
%
%   If DIMS is not specified, FLIPDIMS will flip along the first non-
%   singleton dimension.  As a special case, FLIPDIMS(X), where X is a
%   vector, will reverse the order of the elements of X.
%
%   Note that the multiplicity of the elements in DIMS does matter.
%   Flipping an even number of times along a dimension changes nothing.
%
%   See also FLIPDIM, FLIPLR, FLIPUD, ROT90, PERMUTE.

%   Author:      Peter J. Acklam
%   Time-stamp:  2001-06-04 23:42:52 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   nargsin = nargin;
   error(nargchk(1, 2, nargin));

   sx = size(x);
   dx = ndims(x);

   % if dimension vector is not given, get first non-singleton dimension
   if nargsin < 2                       % no dimension vector specified
      k = find(sx > 1);                 % find non-singleton dimensions
      if isempty(k)                     % if no non-singleton dimensions
         y = x;                         %   output is identical to input
         return;                        %   bail out
      end
      dims = k(1);                      % pick first non-singleton dimension

   % if dimension vector is given, check it
   else
      if sum(size(dims) > 1) > 1 | any(dims < 1)
         error('DIMS must be a vector of values >= 1.');
      end
      dims = fix(dims);                 % make sure values are integers
      dims = dims(dims <= dx);          % dim is singleton if dim > ndims(x)
      dims = dims(sx(dims) > 1);        % dim is singleton if sx(dim) = 1
      if isempty(dims)                  % if no non-singleton dimensions
         y = x;                         %   output is identical to input
         return;                        %   bail out
      end

   end

   % create the list of subscripts
   idx{dx} = ':';
   idx(:) = idx(end);
   for i = 1:length(dims)
      n = sx(dims(i));                  % length along dimension dims(i)
      if n > 1                          % flipping is a null-op if n <= 1
         if isequal(idx{dims(i)}, ':')  % if dimension not flipped
            idx{dims(i)} = n:-1:1;      %    then flip it
         else                           % otherwise
            idx{dims(i)} = ':';         %    flip again (i.e., no change)
         end
      end
   end

   % now flip dimensions
   y = x(idx{:});
