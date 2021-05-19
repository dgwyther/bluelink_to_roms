function rec = op_rotate( rec, idx, grid )

% Find the appropriate records
vars={'Uwind' 'Vwind'};
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

angler=nanmean(grid.angle(:));
u = rec.var(idx(1)).data*cos(angler) - rec.var(idx(2)).data*sin(angler);
v = rec.var(idx(2)).data*cos(angler) + rec.var(idx(1)).data*sin(angler);
rec.var(idx(1)).data = u;
rec.var(idx(2)).data = v;
