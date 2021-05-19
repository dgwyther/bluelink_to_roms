load jason_cycle_times.mat

jason_cycle_date = datestr(tpjason_time(jason_cycle_times(:,2)),'mm/dd/yyyy');
jason_cycle_vals = datevec(tpjason_time(jason_cycle_times(:,2)));
jason_cycle_month = datestr(tpjason_time(jason_cycle_times(:,2)),'mmmyyyy');
for i=1:length(jason_cycle_vals),
  jason_cycle_yearnum(i) = yearnum(datenum(jason_cycle_vals(i,1),jason_cycle_vals(i,2), ...
                              jason_cycle_vals(i,3), ...
                             jason_cycle_vals(i,4),jason_cycle_vals(i,5),...
                             jason_cycle_vals(i,6)));
end
jason_cycle_yearnum = jason_cycle_yearnum';
clear i;
