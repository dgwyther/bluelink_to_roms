function y = flipfb(x)
%FLIPFB Flip matrix in front/back direction.
%
%   FLIPFB(X) returns X flipped in the front/back direction, i.e., flipped
%   along the third dimension with all other dimensions preserved.
%
%   For example,
%
%     X(:,:,1) =  1   2   3     X(:,:,2) =  7   8   9
%                 4   5   6                10  11  12
%
%   becomes
%
%     X(:,:,1) =  7   8   9     X(:,:,2) =  1   2   3
%                10  11  12                 4   5   6
%
%   See also FLIPLR, ROT90, FLIPDIM.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:19:47 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   y = flipdim(x, 3);
