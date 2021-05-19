function [fit, coef] = harmfit(x, y, period, harmonic, mean, linear)

% function fit = harmfit(x, y, period, mean, linear)
%
% Harmonic series fit to a function
%
% Based on HARMFIT.PRO for IDL by E. Leuliette & C. Torrence, April 15, 1993
%
% Provide the time, x, the data, y, the period of the time steps,
% the number of harmonic frequencies to match, whether to remove the mean 
% (mean=1) and whether to remove a linear time component (linear=1)

% Check for input data
if ( nargin < 2 )
  error('you must provide a time and data vector');
elseif ( nargin < 3 )
  period = 1;
  harmonic = 1;
elseif ( nargin < 4 )
  harmonic = 1;
  mean = 1;
  linear = 1;
elseif ( nargin < 5 )
  mean = 1;
  linear = 1;
elseif ( nargin < 6 )
  linear = 1;
end

% Check the lengths
n=length(x);
if ( length(y) ~= n )
  error('vectors must be same length');
end
x=reshape(x,n,1);
y=reshape(y,n,1);

% Put the time in a periodic step
omegatime = 2*pi/period * x;
terms = 2*harmonic;

% Format the regression matrix
comp = zeros(n, terms+2);
comp(:,1) = ones(n, 1);
comp(:,2) = x;
for i=1:harmonic,
  comp(:,i*2+1) = sin(omegatime * i);
  comp(:,i*2+2) = cos(omegatime * i);
end

% Check the options
if ( linear ~= 1 )
  comp = comp(:, [1 3:end]);
end
if ( mean ~= 1 )
  comp = comp(:,2:end);
end

% Do the regression
coef = comp \ y;
fit = comp * coef;