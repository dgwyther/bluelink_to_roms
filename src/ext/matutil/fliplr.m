function y = fliplr(x)
%FLIPLR Flip matrix in left/right direction.
%
%   FLIPLR(X) returns X flipped in the left/right direction, i.e., flipped
%   along the second dimension with all other dimensions preserved.
%
%   For example,
%
%     X(:,:,1) =  1   2   3     X(:,:,2) =  7   8   9
%                 4   5   6                10  11  12
%
%   becomes
%
%     X(:,:,1) =  3   2   1     X(:,:,2) =  9   8   7
%                 6   5   4                12  11  10
%
%   See also FLIPLR, ROT90, FLIPDIM.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:19:50 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   y = flipdim(x, 2);
