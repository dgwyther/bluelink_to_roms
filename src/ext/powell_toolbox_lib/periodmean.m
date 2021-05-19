function m = periodmean( data, steps )

% function m = periodmean( data, steps )
%
% This function will compute the mean  of
% the given 3 dimensional data over the number of steps specified.

if ( nargin < 2 )
  error('You must specify data and steps');
end
if ( nargin < 3 )
  dim = 1;
end

len = size(data,1);
m = [];
count = 1;
for i=[1:steps+1:len],
  if ( i + steps > len )
    continue;
  end
  m(count,:,:) = mean( data(i:i+steps,:,:), 1 );
  count = count + 1;
end
return