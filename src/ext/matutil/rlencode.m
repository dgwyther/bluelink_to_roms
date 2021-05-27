function [len, val, first, last] = rlencode(x, nanflag)
%RLENCODE Run-length encode a vector.
%
%   [LEN, VAL] = RLENCODE(X) returns a vector LEN with the length of each
%   run and a vector VAL with the corresponding values.  LEN and VAL have
%   the same lengths.  X must be a vector.
%
%   [...] = RLENCODE(X, NANFLAG) will compress sequences of NaN's if NANFLAG
%   is 1 (or, more precisely, something that evaluates to true).  This will
%   slow down RLENCODE a little, though.
%
%   Examples: rlencode([ 6 6 4 4 4 5 8 8 7 7 7 7 ]) returns
%
%      len = [ 2 3 1 2 4 ];     % run lengths
%      val = [ 6 4 5 8 7 ];     % values
%
%   rlencode([ 6 6 NaN NaN NaN 5 8 8 7 7 7 7 ]) returns
%
%      len = [ 2  1   1   1  1 2 4 ];   % run lengths
%      val = [ 6 NaN NaN NaN 5 8 7 ];   % values
%
%   rlencode([ 6 6 NaN NaN NaN 5 8 8 7 7 7 7 ], 1) returns
%
%      len = [ 2  3  1 2 4 ];   % run lengths
%      val = [ 6 NaN 5 8 7 ];   % values
%
%   See also RLDECODE.

%   Author:      Peter J. Acklam
%   Time-stamp:  2001-08-16 00:51:06 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % check number of input arguments
   nargsin = nargin;
   error(nargchk(1, 2, nargsin));

   sx = size(x);
   longdim = sx > 1;
   if sum(longdim) > 1
      error('Input must be a vector.');
   end

   if nargin < 2
      nanflag = 0;
   end

   % make sure input is a column vector
   x = x(:);

   % find positions where one element is different from the next
   if nanflag
      % catching sequences of NaN's makes this a little tricky
      isnanx = isnan(x);
      i = x(1:end-1) ~= x(2:end) & ~(isnanx(1:end-1) & isnanx(2:end));
   else
      % this is fast, but doesn't catch sequences of NaNs
      i = x(1:end-1) ~= x(2:end);
   end

   % now find the run lengths and values
   last = [ find(i) ; length(x) ];      % end position for each run
   len = diff([ 0 ; last ]);            % length of each run
   val = x(last);                       % value of each run

   % make sure that the output is a vector in the same dimension as input
   sout = sx;
   sout(longdim) = length(len);
   len = reshape(len, sout);
   val = reshape(val, sout);

   if nargout > 2
      first = last - len + 1;
   end
