function y = tpjason_cycle_yearnum(cycle)

% This function, given a TOPEX or Jason time in seconds
% returns the date/time string
[y,mo,d,h,m,s] = datevec(tpjason_time(cycle));
for i=1:length(cycle)
  y(i) = yearnum(y(i),mo(i),d(i),h(i),m(i),s(i));
end