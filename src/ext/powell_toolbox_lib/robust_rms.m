function r = robust_rms(x)

% function r = robust_rms(x)
%
% Given a vector of data, ignoring the nan's, compute the robust RMeanS

if ( nargin<1 | isempty(x) )
  error('Incorrect Arguments');
end

l = find( ~isnan(x) );
if ( isempty(l) )
  r = nan;
else
  n = sort(x(l));
  d = floor(length(n)*.105);
  r = sqrt( mean( n( d:end-d).^2 ));
end