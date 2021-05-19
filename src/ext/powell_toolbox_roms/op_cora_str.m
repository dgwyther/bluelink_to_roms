function rec = op_cora_str( rec, idx, grid )

% Compute the wind stress from the wind speed -- This is the algorithm
% from the CORA group.

rec.vars = 1;
sp         =  sqrt ( rec.var(1).data.^2 + rec.var(2).data.^2 );
rhocdsp    =  (0.00270   +  0.000142*sp  +  0.0000764*sp.^2) * 1.2;
rec.var(1).data = rhocdsp .* rec.var(1).data;
rec.var(2).data = rhocdsp .* rec.var(2).data;
