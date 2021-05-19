function obs = obs_read( file )

try
  obs.filename     = file;
  obs.spherical    = nc_varget(file, 'spherical');
  obs.nobs         = nc_varget(file, 'Nobs');
  obs.survey_time  = nc_varget(file, 'survey_time');
  obs.survey       = length(obs.survey_time);
  obs.variance     = nc_varget(file, 'obs_variance');
  obs.type         = nc_varget(file, 'obs_type');
  obs.time         = nc_varget(file, 'obs_time');
  obs.depth        = nc_varget(file, 'obs_depth');
  obs.x            = nc_varget(file, 'obs_Xgrid');
  obs.y            = nc_varget(file, 'obs_Ygrid');
  obs.z            = nc_varget(file, 'obs_Zgrid');
  obs.error        = nc_varget(file, 'obs_error');
  obs.value        = nc_varget(file, 'obs_value');
  try
    obs.lat        = nc_varget(file, 'obs_lat');
  catch
    true;
  end
  try
    obs.lon        = nc_varget(file, 'obs_lon');
  catch
    true;
  end
  try
    obs.provenance = nc_varget(file, 'obs_provenance');
  catch
    true;
  end
  try
    obs.meta       = nc_varget(file, 'obs_meta');
  catch
    true;
  end
catch
  disp(['ERROR: There is a problem with the file: ' file]);
  obs = [];
end
