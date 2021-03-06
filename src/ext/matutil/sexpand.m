function varargout = sexpand(varargin)
%SEXPAND Scalar expansion.
%
%   [XE, YE, ZE, ...] = SEXPAND(X, Y, Z, ...) performs scalar expansion
%   on the input arguments.  The output arguments will all have the same
%   size.
%
%   All non-scalar arguments must have the same size.  All scalars are
%   expanded to the size of the non-scalar arguments.
%
%   See also RESIZE, GSEXPAND.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:50:36 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % check number of input and output arguments
   %

   nargsin = nargin;
   if nargsin < 2
      error('Not enough input arguments.');
   end

   nargsout = nargout;

   % when called with no output arguments, return one output argument
   if nargsout == 0
      nargsout = 1;
   end

   if nargsout > length(varargin)
      error('Too many output arguments.');
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % find the size of the output arguments
   %

   % initialize common size vector and number of dimensions and elements
   csize  = size(varargin{1});
   cdims  = length(csize);
   celems = prod(csize);

   for i = 2:nargsin

      % size and number of dimensions and elements for i'th input argument
      isize  = size(varargin{i});
      idims  = length(isize);
      ielems = prod(isize);

      if ielems ~= 1
         if celems == 1
            % if the i'th input argument is not a scalar, but the common
            % size is, update the common size
            csize  = isize;
            cdims  = idims;
            celems = ielems;
         else
            if ~isequal(isize, csize)
               error('Non-scalar arguments must all have the same size.');
            end
         end
      end

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % initialize output argument list and call other program
   %

   varargout = cell(1, nargsout);
   [varargout{:}] = resize(csize, varargin{:});
