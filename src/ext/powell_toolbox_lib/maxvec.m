function m = maxvec(x,y)
%   MAXVEC   Compute the maximum between two randomly sized vectors
%     [M] = MAXVEC(X,Y)
% 
%   If two vectors, x and y, are differently sized, we still aim
%   to find the maximum of equal size to the largest.
%   
%   Created by Brian Powell on 2010-12-02.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.

if nargin<2
  error('you must specify two vectors');
end
x=x(:);
y=y(:);
d=length(x)-length(y);
if d>0
  y=padarray(y,d,'post');
elseif d<0,
  x=padarray(x,-d,'post');
end
m=max(x,y);

end %  function
