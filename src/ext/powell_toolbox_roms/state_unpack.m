function state = state_unpack(statevec, grid)
%   STATE_UNPACK   Pack the given state file into a matrix
%     [STATE] = STATE_PACK(STATEVEC, GRID)
% 
%   Unpack the state vector back into an ocean state
%   
%   Created by Brian Powell on 2008-08-14.
%   Copyright (c)  powellb. All rights reserved.

if (nargin~=2)
  error('incorrect arguments');
end

g=grid_read(grid);

nt = size(statevec,2);

% Compute the sizes
oceanr2 = find(g.maskr'==1);
oceanu2 = find(g.masku'==1);
oceanv2 = find(g.maskv'==1);
nr2   = length(oceanr2);
nu2   = length(oceanu2);
nv2   = length(oceanv2);
nlev  = (size(statevec,1)-nr2-nu2-nv2)/(2*nr2+nu2+nv2);

oceanr3 = find(repmat(g.maskr',[1 1 nlev])==1);
oceanu3 = find(repmat(g.masku',[1 1 nlev])==1);
oceanv3 = find(repmat(g.maskv',[1 1 nlev])==1);
nr3   = length(oceanr3);
nu3   = length(oceanu3);
nv3   = length(oceanv3);

% Create the state
state.zeta = zeros([nt size(g.maskr')]);
state.ubar = zeros([nt size(g.masku')]);
state.vbar = zeros([nt size(g.maskv')]);
state.u    = zeros([nt size(g.masku') nlev]);
state.v    = zeros([nt size(g.maskv') nlev]);
state.temp = zeros([nt size(g.maskr') nlev]);
state.salt = zeros([nt size(g.maskr') nlev]);

% Unpack the data
statevec=statevec';
for t=1:nt,
  state.zeta(t,oceanr2) = statevec(t,1:nr2);
  idx=nr2;
  state.ubar(t,oceanu2) = statevec(t,idx+1:idx+nu2);
  idx=idx+nu2;
  state.vbar(t,oceanv2) = statevec(t,idx+1:idx+nv2);
  idx=idx+nv2;
  state.u(t,oceanu3) = statevec(t,idx+1:idx+nu3);
  idx=idx+nu3;
  state.v(t,oceanv3) = statevec(t,idx+1:idx+nv3);
  idx=idx+nv3;
  state.temp(t,oceanr3) = statevec(t,idx+1:idx+nr3);
  idx=idx+nr3;
  state.salt(t,oceanr3) = statevec(t,idx+1:idx+nr3);
end

% Reorder the structure
state.zeta = permute(state.zeta, [1 3 2]);
state.ubar = permute(state.ubar, [1 3 2]);
state.vbar = permute(state.vbar, [1 3 2]);
state.u    = permute(state.u   , [1 4 3 2]);
state.v    = permute(state.v   , [1 4 3 2]);
state.temp = permute(state.temp, [1 4 3 2]);
state.salt = permute(state.salt, [1 4 3 2]);


end %  function