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
newdat = zeros(size(rec.var(idx(1)).data));
for t=2:size(rec.var(idx(1)).data,1),
  newdat(t,:) = (rec.var(idx(1)).data(t,:) - rec.var(idx(1)).data(t-1,:)) / ...
                              (( rec.var(idx(1)).data_time(t) - rec.var(idx(1)).data_time(t-1) )*86400);
end
rec.var(idx(1)).data=newdat;
rec.var(idx(2)).data=[];
