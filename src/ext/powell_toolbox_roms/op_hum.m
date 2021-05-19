function rec = op_hum( rec, idx, grid )

% Find the appropriate records
vars={'Qair' 'Tair' 'Pair'};
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

% wv = -rec.var(idx(1)).data/1000 ./ ( rec.var(idx(1)).data/1000 - 1);
wv = -rec.var(idx(1)).data ./ ( rec.var(idx(1)).data - 1);
% wv = rec.var(idx(1)).data;
es = 6.1078 * exp( 19.8*rec.var(idx(2)).data ./ (rec.var(idx(2)).data + 273.15));
ws = 0.62197 * ( es ./ (rec.var(idx(3)).data - es) );
rec.var(idx(1)).data = wv./ws * 100;
rec.var(idx(1)).data( rec.var(idx(1)).data>100 )=100;
