function statevec = state_pack(file, grid)
%   STATE_PACK   Pack the given state file into a matrix
%     [STATEVEC] = STATE_PACK(FILE, GRID)
% 
%   Load the given file and pack each time state into a single vector
%   combining all times into a single column matrix
%   
%   Created by Brian Powell on 2008-08-14.
%   Copyright (c)  powellb. All rights reserved.

if (nargin~=2)
  error('incorrect arguments');
end
if ( ~exist(file,'file') )
  error(['cannot find file: ' file])
end

g=grid_read(grid);

zeta = permute(nc_varget( file, 'zeta' ), [ 1 3 2]);
ubar = permute(nc_varget( file, 'ubar' ), [ 1 3 2]);
vbar = permute(nc_varget( file, 'vbar' ), [ 1 3 2]);
u    = permute(nc_varget( file, 'u' ), [ 1 4 3 2]);
v    = permute(nc_varget( file, 'v' ), [ 1 4 3 2]);
temp = permute(nc_varget( file, 'temp' ), [ 1 4 3 2]);
salt = permute(nc_varget( file, 'salt' ), [ 1 4 3 2]);

nlev = size(u,4);
nt   = size(u,1);

oceanr2 = find(g.maskr'==1);
oceanu2 = find(g.masku'==1);
oceanv2 = find(g.maskv'==1);
nr2   = length(oceanr2);
nu2   = length(oceanu2);
nv2   = length(oceanv2);

oceanr3 = find(repmat(g.maskr',[1 1 nlev])==1);
oceanu3 = find(repmat(g.masku',[1 1 nlev])==1);
oceanv3 = find(repmat(g.maskv',[1 1 nlev])==1);
nr3   = length(oceanr3);
nu3   = length(oceanu3);
nv3   = length(oceanv3);

for t=1:nt,
  if ( t>1 )
    statevec(t,:) = zeros(size(statevec(1,:)));
  end
  statevec(t,1:nr2) = zeta(t,oceanr2);
  idx=nr2;
  statevec(t,idx+1:idx+nu2) = ubar(t,oceanu2);
  idx=idx+nu2;
  statevec(t,idx+1:idx+nv2) = vbar(t,oceanv2);
  idx=idx+nv2;
  statevec(t,idx+1:idx+nu3) = u(t,oceanu3);
  idx=idx+nu3;
  statevec(t,idx+1:idx+nv3) = v(t,oceanv3);
  idx=idx+nv3;
  statevec(t,idx+1:idx+nr3) = temp(t,oceanr3);
  idx=idx+nr3;
  statevec(t,idx+1:idx+nr3) = salt(t,oceanr3);
  idx=idx+nr3;
end
statevec=statevec';

end %  function