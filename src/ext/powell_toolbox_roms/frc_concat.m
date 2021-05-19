function frc_concat( frcdir, frcfile, times, epoch )
% Generate a forcing file by combining a number of atmospheric files together

% Go from the first time, by three hours to the end
times=[floor(times(1)):0.125:floor(times(end))];

% Find all available files in the directory
files=ls_files(frcdir,'nc');
if ( isempty(files) )
  return
end


% Construct the forcing structure
vars = { 'tair' 'rain' 'pair'  'wind' 'lwrad' 'swrad' 'qair' };
frc = gfs_nc_info(vars, char(files(1)), false);

% Go through each file and all variables to piece all of the data together
% This is done from the earliest to the latest so that the fewest number of
% forecast records are used.
for f=1:length(files),
  disp(files(f));
  for v=1:frc.vars,
    t=nc_varget(char(files(f)),frc.var(v).time_str)+epoch;
    t=round(t*1000)/1000;
    [l,m]=vecfind(times,t);
    if isempty(l) continue; end
    data=nc_varget(char(files(f)), frc.var(v).roms_variable_name);
    % Fill the data
    frc.var(v).data_time = times;
    frc.var(v).data(l,:,:) = data(m,:,:);
  end
end

frc.roms_grid=false;
write_netcdf(frc, frcfile, epoch);

