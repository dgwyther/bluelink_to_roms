function y = yearnum( day )

% function y = yearnum( day )
%
% Given a Matlab datenum, compute the fractional year number

[y,m] = datevec(day);
years = datenum(y, 1, 1);
ydays = datenum(y+1, 1, 1) - years;
y = y + ( day - years ) ./ ydays;