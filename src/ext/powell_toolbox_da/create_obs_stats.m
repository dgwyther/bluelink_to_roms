function [varmean, varstd, var] = create_obs_stats( dir, opt, fld )

% This will take a directory of observations data and calculate the
% mean and variance of the field

roms_defs

if (nargin<3)
  fld='value';
end

% First, let's go through the directory given and
% figure out the dates that the files cover
count = 1;
f = ls_files( dir,'nc');
for i=1:length(f),
  fnames(count) = f(i);
  s = nc_varget(char(f(i)),'survey_time');
  ftimes(count,:) = [s(1) s(end)];
  count = count + 1;
end
files = find( opt.times(1) <= ftimes(:,1) & opt.times(end) >= ftimes(:,2) );

% If we have valid files, let's do the dirty work
if ( ~isempty(files) )
  grid = grid_read(opt.grid);
  var.zeta = ones( [length(opt.times) size(grid.maskr)] ) * nan;
  var.u = ones( [length(opt.times) size(grid.masku)] ) * nan;
  var.v = ones( [length(opt.times) size(grid.maskv)] ) * nan;
  var.temp = ones( [length(opt.times) size(grid.maskr)] ) * nan;
  var.salt = ones( [length(opt.times) size(grid.maskr)] ) * nan;
  var.time = ones(length(opt.times),1)*nan;
  var.mse = ones(length(files),8)*nan;
  
  for i=1:length(files),
    obs = obs_read( char(fnames(files(i))) );
    if ( ~isempty(obs) )
      % Go through all state variables and surveys to process the data
      var.mse(i,1)=obs.survey_time(1);
      for v=[isFsur isUvel isVvel isTemp isSalt],
        o = find(obs.type==v);
        var.mse(i,v+1)=nanmean((obs.value(o) - nanmean(obs.value(o))).^2);
        for t=1:length(obs.survey_time)
          o = find(obs.type==v & obs.time==obs.survey_time(t));
          if ( isempty(o) ) continue; end
          idx = find( opt.times == round(obs.survey_time(t)) );
          if ( idx )
            var.time(idx)=opt.times(idx);
            disp(opt.times(idx))
            switch (v)
              case isUvel,
                l = sub2ind(size(grid.latu), round(obs.y(o))+1, round(obs.x(o))+1);
                eval(sprintf('var.u(idx,l) = obs.%s(o);',fld));
              case isVvel,
                l = sub2ind(size(grid.latv), round(obs.y(o))+1, round(obs.x(o))+1);
                eval(sprintf('var.v(idx,l) = obs.%s(o);',fld));
              otherwise,
                l = sub2ind(size(grid.latr), round(obs.y(o))+1, round(obs.x(o))+1);
                eval(sprintf('var.%s(idx,l)=obs.%s(o);',char(isVars(v)),fld));
            end
          end
        end
      end
    end
  end
end

% Go through our data and package it up
for v=[isFsur isUvel isVvel isTemp isSalt],
  eval(sprintf('varmean.%s=nanmean(var.%s);',char(isVars(v)),char(isVars(v))));
  eval(sprintf('varstd.%s=nanstd(var.%s);',char(isVars(v)),char(isVars(v))));
end
