function ssh = ssh_nc_info( tstart, tend, interp_grid )

% function ssh = ssh_nc_info( tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed 
% for saving altimetry data into the ROMS netcdf format.

if ( nargin < 3 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
tvec = datevec([tstart:tend]);
year = unique(tvec(:,1));
ssh.time_start = tstart;
ssh.time_end = tend;
ssh.interp_grid = interp_grid;

% Grab the correct information
ssh.vars                      = 1;
ssh.var(1).roms_variable_name = 'SSH';
ssh.var(1).long_name          = 'sea surface height observations';
ssh.var(1).roms_offset        = 0;
ssh.var(1).roms_scale         = 1;
ssh.var(1).units              = 'meter';
ssh.var(1).time_str           = 'SSHobs_time';
ssh.var(1).field              = 'SSHobs, scalar, series';
