function var = create_monthly_obs_variance( dir, opt )

% CREATE_MONTHLY_OBS_VARIANCE   Create monthly mean variances for obs
%
% This will take a directory of observations data and calculate monthly
% variance means to be used in the data assimilation
% 
% SYNTAX
%   VAR = CREATE_MONTHLY_OBS_VARIANCE( DIR, OPT )
% 
% Specify opt.times = [start:end] for the data you want to use to generate
%                     the climatology from

roms_defs

[vm,vs,var] = create_obs_stats(dir, opt, 'error');

% Next, break everything from beginning to end into monthly increments
beg_year = datevec(opt.times(1) + opt.epoch);
beg_year = beg_year(1);
day1 = datenum(beg_year,1,1) - opt.epoch;
factor = 12/(datenum(beg_year+1,1,1)-datenum(beg_year,1,1));

% Put the opt.times vector into month numbers
mon = mod(floor((opt.times-day1)*factor)+1,12);
mon(find(~mon))=12;

% Go through our data and package it up
for v=[isFsur isUvel isVvel isTemp isSalt],
  data=eval(sprintf('var.%s',char(isVars(v))));
  s=size(data);
  s(1)=12;
  newdata=ones(s)*nan;
  % Make sure we have something
  if ( length(find(~isnan(data(:)))) )
    for m=1:12,
      l = find( mon==m );
      newdata(m,:) = nanmean( data(l,:) );
    end
    eval(sprintf('var.%s=newdata;',char(isVars(v))));
  else
    var = rmfield(var, char(isVars(v)));
  end
end
