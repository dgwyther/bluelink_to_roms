function svar = slopevar(data, area,type)

% function svar = slopevar(data, area, type)
%
% Compute the slope variance from the given data over the area
% for the type of data specified
%
% type is one of:
% 'tp2' for T/P 2
% 'hi' for hirate data
% 'tp2hi' for T/P 2 hirate data
% 'default' for 1Hz nominal T/P or Jason-1

if ( nargin < 2 )
  error('You must specify an area and data');
end
if ( nargin ~= 3 )
  type = 'default';
end

if ( isempty(area) )
  return;
end

switch lower(type)
  case 'tp2'
    global alongtrack_tp2
    ref = 'alongtrack_tp2';
    if ( ~exist('alongtrack_tp2', 'var') | isempty(alongtrack_tp2) )
      fprintf(1,'Loading alongtrack_tp2');
      load alongtrack_tp2;
    end
  case 'hi'
    global alongtrack_hi
    ref = 'alongtrack_hi';
    if ( ~exist('alongtrack_hi', 'var') | isempty(alongtrack_hi) )
      fprintf(1,'Loading alongtrack_hi');
      load alongtrack_hi;
    end
  case 'tp2hi'
    global alongtrack_tp2hi
    ref = 'alongtrack_tp2hi';
    if ( ~exist('alongtrack_tp2hi', 'var') | isempty(alongtrack_tp2hi) )
      fprintf(1,'Loading alongtrack_tp2hi');
      load alongtrack_tp2hi;
    end
  otherwise
    global alongtrack
    ref = 'alongtrack';
    if ( ~exist('alongtrack', 'var') | isempty(alongtrack) )
      fprintf(1,'Loading alongtrack');
      load alongtrack;
    end
end

% Compute the sin squared of the latitude
eval(sprintf('lat2 = sin(deg2rad(%s.lat(area))).^2;',ref));

% Convert the alongtrack slopes to geostrophic currents
geo = along_geostrophic(data, area) .* lat2;

% EKE is the variance of the geostrophic
%svar = nanvar(geo);
good = find(~isnan(geo));
svar = var(geo(good));