function rec = op_plus( rec, idx, grid )

num_vars = length(rec.var)-idx;
rec.vars = idx;
for v=idx+1:num_vars,
 rec.var(idx).data = rec.var(idx).data + rec.var(v).data;
 rec.var(v).data = 0;
 rec.var(v).data_time = 0;
end
