function y = largest(a, dim)
%   LARGEST   FIND THE LARGEST MAGNITUDE VALUE (+ or -)
%     [Y] = LARGEST(A, DIM)
% 
%   Given an array, A, find the largest magnitude value, whether
%   positive or negative in the dimension
%   
%   Created by Brian Powell on 2011-12-07.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.

if nargin<2,
  dim = min(find(size(a)~=1));
  if isempty(dim), dim = 1; end
end
if ndims(a) < dim,
  error('dimension invalid');
end

y=max(a,[],dim);
mn=min(a,[],dim);
l=find(y<abs(mn));
y(l)=mn(l);

end %  function