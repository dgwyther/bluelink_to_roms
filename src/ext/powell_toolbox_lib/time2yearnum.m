function y = time2yearnum(d)
%time2yearnum Ordinal year number.
%
%   YEARNUM(datenum) returns the ordinal year
%   number plus a fractional part depending on the month, day, and time of
%   day.
%
  if ( nargin ~= 1 )
    error('you must specify a datenum');
  end
   [year, month, day, hour, minute, second] = datevec(d);

%  The timeutils I am using are rather limited and don't work in vector
% form. Until I can find new ones, we are forced to live with for loops
for i=1:length(d),
   y(i)=year(i) + (dayofyear(year(i), month(i), day(i), hour(i), minute(i), second(i)) - 1) ...
          ./ daysinyear(year(i));
end
y=reshape(y,size(d));
