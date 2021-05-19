function geo = geostrophic(data, lat)

% function geo = geostrophic(data, lat)
%
% Given a vector of data (dh/dx) and a vector of latitudes, compute
% the geostrophic current, u.


if ( nargin < 2 )
  error('You must specify data and latitude');
end

% Compute the orthogonal along-track geostrophic current
% The along track data is assumed to be in mm/s
% Result is in cm/s
geo = -980.665 ./ ( 2 * 7.272e-5 .* sin(deg2rad(lat))) .* data;
return
