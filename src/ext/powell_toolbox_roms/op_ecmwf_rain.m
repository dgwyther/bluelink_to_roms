function rec = op_rain( rec, idx, grid )

% Find the appropriate records
vars={'rain' 'rainnc'};
idx=nan(length(vars),1);
for v=1:length(vars),
  for r=1:length(rec.var),
    if (strcmp(char(vars(v)),rec.var(r).roms_variable_name))
      idx(v)=r;
      break;
    end
  end
end
if (find(isnan(idx)))
  error('missing required field')
end

% Add the rain fields together and divide by the time
rec.var(idx(1)).data = rec.var(idx(1)).data + rec.var(idx(2)).data;
dt=diff(rec.var(idx(1)).data_time)*86400;
dt=[mean(dt); dt(:)];
for t=1:length(dt),
  rec.var(idx(1)).data(t,:) = rec.var(idx(1)).data(t,:) ./ dt(t);
end
rec.var(idx(2)).data=[];
