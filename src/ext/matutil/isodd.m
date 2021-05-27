function b = isodd(x)
%ISODD True for even numbers.
%
%   ISODD(X) returns 1's where the elements of X are odd numbers and 0's
%   where they are not.
%
%   See also ISINT, ISEVEN.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:20:28 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));
   if ~isnumeric(x)
      error('Argument must be a numeric array.');
   end

   cls = class(x);                      % class of input argument
   if isempty(x)
      b = feval(cls, x);                % return empty array of same class
   else
      switch cls
         case 'double'
            b = rem(x, 2) == 1;
         case 'single'
            % convert input to double, compare, and convert back
            b = single(rem(double(x), 2) == 1);
         case {'uint8', 'uint16', 'uint32'}
            % return an array of ones of the same class as input argument
            b = bitand(x, 1);
         case {'int8', 'int16', 'int32'}
            error('Not implemented for classes int8, int16, and int32.');
         otherwise
            error('Argument is of unrecognized class.');
      end
   end
