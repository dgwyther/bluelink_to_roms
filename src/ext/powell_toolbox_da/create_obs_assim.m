function create_obs_assim( opt )

% obs = create_obs_assim( opt )
%
% This function provides a method to search for and merge together all
% given observation directories over the period specified.
%

% First, let's go through all of the directories given and
% figure out the dates that they cover
count = 1;
for d=1:length(opt.dirs),
  f = ls_files( char(opt.dirs(d)),'nc' );
  for i=1:length(f),
    fnames(count) = f(i);
    s = nc_varget(char(f(i)),'survey_time');
    ftimes(count,:) = [s(1) s(end)];
    count = count + 1;
  end
end

if ( isfield(opt,'variance' ) )
  for i=1:6,
    if ( ~iscellstr(opt.variance(i)) ) continue; end
    load(char(opt.variance(i)));
  end
end

% With all of the file information, go over all of the times for the
% observation files and merge them together
for t=1:length(opt.times)-1,
  l = find( (opt.times(t) <= ftimes(:,1) & opt.times(t+1) >= ftimes(:,1)) | ...
            (opt.times(t) >= ftimes(:,1) & opt.times(t+1) <= ftimes(:,2)) | ...
            (opt.times(t) <= ftimes(:,2) & opt.times(t+1) >= ftimes(:,2)) );
  if ( ~isempty(l) )
    obs = obs_merge( fnames(l), opt );
    obs = obs_period( obs, opt.times(t), opt.times(t+1) );
    obs.filename = regexprep(opt.obs_out,'#*',num2str(opt.times(t)));
    % Clean up the observations, set the variance to be consistent
    if ( isfield(opt,'variance' ) )
      [y,mon] = datevec( obs.survey_time + opt.epoch );
      u = unique(mon(~isnan(mon)));
      weight = [];
      for m=1:length(u),
        weight(m,:) = [ u(m) length(find(mon==u(m)))/length(mon)];
      end
      flds = unique(obs.type');
      for f=flds,
        v = find( obs.type == f );
        if ( ~iscellstr(opt.variance(f)) ) continue; end
        eval(sprintf('var = %s;',char(opt.variance(f))));
        tmp = var(1,:,:) * 0;
        for m=1:size(weight,1),
          disp(['   variance from ' char(opt.variance(f)) ' month ' num2str(weight(m,1))]);
          tmp = tmp + var(weight(m,1),:,:)*weight(m,2);
        end
        obs.error(v) = nanmax( opt.varinfo(f), ...
          tmp(1,sub2ind( size(squeeze(tmp)), round(obs.y(v))+1, round(obs.x(v))+1 )));
      end
    end
    disp(['writing ' obs.filename]);
    obs_write( obs );
  end
end
