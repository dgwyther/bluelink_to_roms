function skill = compute_persistence( files, grid, region, mss )

% skill = compute_persistence( files, grid, region, mss )
%

vars = {'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt'};
dims = [  3       3      3    4   4    4      4];
grd =  [ 'r'     'u'    'v'  'u' 'v'   'r'   'r'];
numstats = length(calc_stats( 1, 2, 3, 4 ));

progress(0,0,1)
for f=1:length(files.his),
  progress(length(files.his),f,1)

  o=obs_read(char(files.obs(f)));

  % Try to Handle every type of observation in the file
  obs_vars=unique(o.type)';
  for v=obs_vars,
    eval(sprintf('mask = grid.mask%c;',grd(v)));
    if ( dims(v) == 3)
      data = squeeze(nc_varget(char(files.his(f)), char(vars(v)), ...
                      [0 0 0], [1 -1 -1]));
      [x,y]=meshgrid([1:size(data,2)],[1:size(data,1)]);
      data = squeeze(convolve_land( data, mask, 5 ));
    else
      data = squeeze(nc_varget(char(files.his(f)), char(vars(v)), ...
                      [0 0 0 0], [1 -1 -1 -1]));
      [x,y,z]=meshgrid([1:size(data,3)],[1:size(data,2)],[1:size(data,1)]);
      data = convolve_land( data, mask, 5 );
      data = permute(data,[ 2 3 1 ]);
    end
    
    % Remove the MSS
    if ( v == 1 )
      % Remove the MSS from the SSH
      data = data - mss;
      l = find( o.type == 1 );
      nmss=interp2(x,y,mss,o.x(l)+1,o.y(l)+1);
      o.value(l) = o.value(l) - nmss;
    end
    
    % Go over all of the regions
    for r=1:length(region),
      reg = find(inpolygon(o.x+1, o.y+1, region(r).vert(1,:), ...
                  region(r).vert(2,:)) & o.type==v );
      time=unique(o.survey_time);
      skill(f,r).var(v).time = time;
      skill(f,r).var(v).day = ones(length(time),numstats)*nan;

      % Set up the global
      if (dims(v) == 3)
        nv=interp2(x,y,data,o.x(reg)+1,o.y(reg)+1);
      else
        nv=interp3(x,y,z,data,o.x(reg)+1,o.y(reg)+1,o.depth(reg));
      end
      skill(f,r).var(v).global = calc_stats(nv, o.value(reg), nv, o.error(reg));

      % Do each day separately
      for t=1:length(time),
        l = find(o.time(reg)==time(t));
        if ( ~isempty(l) )
           skill(f,r).var(v).day(t,:) = calc_stats(nv(l), o.value(reg(l)), ...
                                                   nv(l), o.error(reg(l)));
        end
      end
    end
  end
end
