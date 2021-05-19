function [s,m,y,h,mn,sec] = season(t)

% function [s,m] = season(t)
%
% Given a time, return the month and season. Seasons are:
% 1-winter, 2-spring, 3-summer, 4-fall

if nargin < 1
  error('you must specify a time');
end

[y,m,d,h,mn,sec]=datevec(t);
s=floor(mod(m,12)/3) + 1;
