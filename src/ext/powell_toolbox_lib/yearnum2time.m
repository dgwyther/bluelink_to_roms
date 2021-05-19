function d = yearnum2date(y)
%YEARNUM2TIME Convert from Ordinal Day.
%
%   yearnum2time(y) returns the matlab time record
%   from the ordinal day.

nargsin = nargin;
error(nargchk(1, 1, nargsin));
year = floor(y);
if ( year < 1900 ) year = year + 1900; end
days = daysinyear(year) .* (y - floor(y));
o = ones(size(year));
d = datenum(year,o,o) + days;
