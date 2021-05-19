function rec = op_dqdsst( rec, idx, grid )
%  Compute dQdSST.
%  dQdSST = - 4 * eps * stef * T^3  - rho_atm * Cp * CH * U
%           - rho_atm * CE * L * U * 2353 * ln (10 * q_s / T^2)
%
% This is taken from Penven
%
% var(1) is sst
% var(2) is tair
% var(3) is rhum
% var(4) is pressure
% var(5) is u-wind
% var(6) is v-wind

% Find the appropriate records
vars={'SST' 'Tair' 'Qair' 'Pair' 'Uwind' 'Vwind'};
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

% Get the air density
U = sqrt( rec.var(idx(5)).data.^2 + rec.var(idx(6)).data.^2 );
clear rec.var(idx(5:6)).data rec.var(idx(5:6)).data_time

rhoa = air_dens( rec.var(idx(2)).data, rec.var(idx(3)).data, rec.var(idx(4)).data );
qsea = (0.01.*rec.var(idx(3)).data).*qsat(rec.var(idx(2)).data,rec.var(idx(4)).data);
clear rec.var(idx(3:4)).data rec.var(idx(3:4)).data_time

rec.var(idx(2)).data = get_dqdsst(rec.var(idx(1)).data,rec.var(idx(2)).data,rhoa,U,qsea);
