function rec = op_swflux( rec, idx, grid )

%
% Calculate the swflux. Formulation from Gill

% The 2.5e6 converts from W m-2 to kg m-2 s-1.
% The 8640 converts from m s-1 to cm day-1
rec.var(idx).data = ( rec.var(idx+1).data./2.5e6 - rec.var(idx+1).data ) .*  8640;
clear rec.var(idx+1).data rec.var(idx+1).data_time
