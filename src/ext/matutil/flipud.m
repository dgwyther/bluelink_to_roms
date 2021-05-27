function y = flipud(x)
%FLIPUD Flip matrix in up/down direction.
%
%   FLIPUD(X) returns X flipped in the up/down direction, i.e., flipped
%   along the first dimension with all other dimensions preserved.
%
%   For example,
%
%     X(:,:,1) =  1   2   3     X(:,:,2) =  7   8   9
%                 4   5   6                10  11  12
%
%   becomes
%
%     X(:,:,1) =  4   5   6     X(:,:,2) = 10  11  12
%                 1   2   3                 7   8   9
%
%   See also FLIPLR, ROT90, FLIPDIM.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:19:53 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   y = flipdim(x, 1);
