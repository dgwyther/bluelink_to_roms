function [c, l] = lagcorr(x)

% function [c, l] = lagcorr(x)
%
% Given a vector, x, return the greatest correlation
% and the lag for that correlation.

len=length(x);
lag=zeros(len,1);
for i=2:len-1,
  cc = corrcoef(x(1:len-i+1),x(i:len));
  lag(i) = cc(2,1);
end
l = min(find(lag==max(lag)));
c = lag(l);