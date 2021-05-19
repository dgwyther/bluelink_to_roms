function reg = regress_series(times, data, periods)

% function reg = regress_series(times, data, periods)
%
% Given times and a set of data, create a regression. periods are the
% number of days to use in each of the frequencies. For instance,
% periods = [ 360 180 ] would give annual and biennial periods
if ( nargin<3 )
  periods=[];
end

% Make sure we are vertical vectors
times = times(:);
data = data(:);

% Do a linear regression
l=find(~isnan(data));
A = [ ones(length(l),1) times(l) ];
for i=1:length(periods),
  sinb = sin(2*pi*times(l)/periods(i));
  cosb = cos(2*pi*times(l)/periods(i));
  A = [ A sinb cosb ];
end

% Compute the fit
x = A \ data(l);

reg.coefs = x;
reg.times = times(l);
reg.trend = x(1) + x(2)*times(l);
