function [corr, zero_cross] = autocorr(x, num_lag)

% function corr = autocorr(x, num_lag)
%
% This function will generate a lagged autocorrelation vector.
% Given the signal and the number of lags, it will return
% a matrix with the lag number in column 1 and the correlation
% in column 2.

% Make sure our signal is a vector
[len,wid] = size(x);
x = reshape(x, len*wid, 1);

corr = ones(2*num_lag+1,2)*nan;
zero_flag = 0;
for lag=0:num_lag,
  s1 = [ ones(lag,1)*nan; x ];
  s2 = [ x; ones(lag,1)*nan ];
  c = nancorrcoef(s1, s2);
  corr(num_lag+1-lag,:) = [ -lag c(2,1) ];
  corr(num_lag+1+lag,:) = [ lag c(2,1) ];
  if ( c(2,1) <= 0 & ~zero_flag )
    zero_cross = [ -lag lag ];
    zero_flag = 1;
  end
end
