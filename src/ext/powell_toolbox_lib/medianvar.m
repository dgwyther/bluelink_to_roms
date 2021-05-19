function var = medianvar(data)

% function var = medianvar(data)
%
% Given a set of data, compute the variance based on the median
% rather than the mean.  Performs:
%
%          1 
%  var = -----  SUM(  (x - xmed )^2 )
%         N-1 

xmed = nanmedian( data );
xmed = xmed(ones(length(data),1),:);
data = data - xmed;
data = data.^2;
var = nansum(data);
n = sum(~isnan(data))-1;
var = var ./ n;