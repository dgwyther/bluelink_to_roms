function rec = op_rhum( rec, idx, grid )

vars={'Qair' 'Tair'};
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

ep = exp( (17.269 * rec.var(idx(1)).data) ./ (273.15 + rec.var(idx(1)).data) );
es = exp( (17.269 * rec.var(idx(2)).data) ./ (273.15 + rec.var(idx(2)).data) );
rec.var(idx(1)).data = ep./es * 100;
