function [year, month, day, hour, minute, second] = yearnum2date(y)
%YEARNUM2DATE Convert from Ordinal Day.
%
%   yearnum2date(y) returns the month, day, and time of
%   day from the ordinal year number.
%

  nargsin = nargin;
  error(nargchk(1, 1, nargsin));
  year = floor(y);
  if ( year < 1900 ) year = year + 1900; end
  days = daysinyear(year) * (y - floor(y)) + 1;
  [month, day, hour, minute, second] = day2date(days, year);