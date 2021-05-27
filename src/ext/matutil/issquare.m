function t = issquare(x)
%ISSQUARE True for square matrix input.
%
%   ISSQUARE(X) returns 1 if it's argument is a square matrix and 0
%   otherwise.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:50:52 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   t = (ndims(x) == 2) & (size(x,1) == size(x,2));
