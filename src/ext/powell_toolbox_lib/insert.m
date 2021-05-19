function u = insert(d, l, val)

% function u = insert(d, l, val)
% Insert the value, val, into every location, l, of vector d

if ( nargin ~= 3 )
  error('invalid arguments');
end

u = ones( length(d) + length(l), 1 ) * val;
l(end+1) = length(d)+1;

nprev = 1;
prev = 1;
for i=1:length(l),
  dist = l(i) - prev;
  u(nprev:nprev+dist-1) = d(prev:prev+dist-1);
  prev = prev + dist;
  nprev = nprev + dist + 1;
end
