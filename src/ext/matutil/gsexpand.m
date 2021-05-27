function varargout = gsexpand(varargin)
%GSEXPAND Generalized scalar expansion.
%
%   [XE, YE, ZE, ...] = GSEXPAND(X, Y, Z, ...) performs a generalized scalar
%   expansion on the input arguments.  The output arguments will all have
%   the same size.
%
%   All arguments are expanded (replicated) along singleton dimensions to
%   match the size of the other arguments.
%
%   See also RESIZE, SEXPAND.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:51:12 +0100
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

   % initialize common size vector and number of dimensions
   csize  = size(varargin{1});
   cdims  = length(csize);

   for i = 2:nargsin

      % size and number of dimensions for i'th input argument
      isize  = size(varargin{i});
      idims  = length(isize);

      if idims <= cdims
         % i'th argument has no more dimensions than the output will have;
         % only compare the `idims' lowest dimensions
         if any( isize(1:idims) ~= 1 & csize(1:idims) ~= 1 ...
                 & isize(1:idims) ~= csize(1:idims) )
            error('Lengths have to match along non-singleton dimensions.');
         end
         csize(1:idims) = max(csize(1:idims), isize(1:idims));
      else
         % i'th argument has more dimensions than the current common size
         % vector; only compare the `cdims' lowest dimensions
         if any( isize(1:cdims) ~= 1 & csize ~= 1 ...
                 & isize(1:cdims) ~= csize )
            error('Lengths have to match along non-singleton dimensions.');
         end
         isize(1:cdims) = max(csize, isize(1:cdims));
         cdims = idims;
      end

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % initialize output argument list and call other program
   %

   varargout = cell(1, nargsout);
   [varargout{:}] = resize(csize, varargin{:});
