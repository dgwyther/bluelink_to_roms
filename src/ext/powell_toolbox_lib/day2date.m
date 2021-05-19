function [month,day,hour,m,sec] = day2date(d,year)

%function [month,day,hour,m,sec] = day2date(d,year)

 nargsin = nargin;
 error(nargchk(2, 2, nargsin));

 days_in_prev_months = [0 31 59 90 120 151 181 212 243 273 304 334];

 if ( isleapyear(year) == 1 )
   days_in_prev_months(3:end) = days_in_prev_months(3:end) + 1;
 end
 days = floor(d);
 time = (d - days).*86400;
 hour = floor(time./3600);
 m = floor(( time - hour.*3600) ./ 60);
 sec = floor(( time - hour.*3600 - m.*60 + 1 ));
 del = days - days_in_prev_months;
 month = max(find(del >= 0));
 day = del(month);
