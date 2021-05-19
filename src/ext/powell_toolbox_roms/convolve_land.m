function field = convolve_land( field, varargin )

% surf = convolve_land( field, [mask, dx, dimension] )
%
% This function will convolve ocean points over the land values for better
% interpolation downstream. 
%
% Example: you have a surface field(time,lat,lon) with a mask(lat,lon)
%     surf = convolve_land( field, mask, 5 )
%   would convolve a 5x5 kernel around all land points, spreading the ocean
%   information over the land.
%

args={'mask' 'dx' 'dim'};
if ( nargin < 1 )
  error('you must provide a field to convolve.')
end
if ( ndims(field) > 3 | ndims(field) < 1 )
  error('field must be 2 or 3 dimensions')
end
if ( ndims(field) == 2 )
  field = reshape(field,[1 size(field)]);
end
dim = 1;
dx = 5;
m = size(field);
mask = ones(m(2),m(3));
for i=1:nargin-1,
  eval(sprintf('%s = varargin{%d};',char(args(i)),i));
end

% Put into dimensions
if ( dim ~= 1 )
  perm = [1:3];
  perm(dim) = [];
  perm = [dim perm];
  field = permute(field,perm);
end

% Calculate the dimensions
[t,m,n] = size(field);

% Set up the mask
mask(find(isnan(mask)))=0;
mask(find(mask))=1;
if ( size(mask) ~= [m n] )
  error('mask must be same size as the field')
end
mask=reshape(mask,[1 size(mask)]);
mask=mask(ones(t,1),:,:);
field=field.*mask;

% Spread the ocean points around, then interpolate to the grid
bounds=[round(dx-1)/2 round(dx-1)/2-1];
kernel = zeros(dx,dx,t);
kernel(:,:,1)=1;
kernel(round((dx+1)/2),round((dx+1)/2),1)=0;
field(find(isnan(field)))=0;
num=permute(convn( permute(mask,[2 3 1]), kernel ),[3 1 2]);
num=num(1:t,bounds(1):m+bounds(2),bounds(1):n+bounds(2));
surf=permute(convn( permute(field.*mask,[2 3 1]), kernel ),[3 1 2]);
surf=surf(1:t,bounds(1):m+bounds(2),bounds(1):n+bounds(2));
list = find( ~mask & num);
field(list) = surf(list) ./ num(list);

if ( dim ~= 1 )
  iperm = [2 3];
  iperm = [iperm(1:dim-1) 1 iperm(dim:end)];
  surf = permute(surf,iperm);
end
