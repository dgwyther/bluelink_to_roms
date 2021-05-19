load tp_cycle_times.mat

tp_cycle_date = datestr(tpjason_time(tp_cycle_times(:,2)),'mm/dd/yyyy');
tp_cycle_vals = datevec(tpjason_time(tp_cycle_times(:,2)));
tp_cycle_month = datestr(tpjason_time(tp_cycle_times(:,2)),'mmmyyyy');
for i=1:length(tp_cycle_vals),
  tp_cycle_yearnum(i) = yearnum(tp_cycle_vals(i,1),tp_cycle_vals(i,2),tp_cycle_vals(i,3), ...
                             tp_cycle_vals(i,4),tp_cycle_vals(i,5),tp_cycle_vals(i,6));
end
tp_cycle_yearnum = tp_cycle_yearnum';
clear i;