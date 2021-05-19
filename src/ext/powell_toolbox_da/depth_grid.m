function nz = depth_grid( obs, opt )

% z = depth_grid( obs, opt )
%
% This function takes a series of x, y, and depths and
% calculates the fractional depth layer of the grid
%

nz = nan * obs.z;
x = floor( obs.x ) + 1;
y = floor( obs.y ) + 1;
xi = x;
opt.z = [ opt.z; zeros(1, size(opt.z,2), size(opt.z,3)) ];
layer = [1:size(opt.z,1)]';
while ( true )
  l = find( ~isnan(xi) );
  if ( isempty(l) ) break; end
  for i=1:length(l),
    m = find( x == x(l(i)) & y == y(l(i)) & ~isnan(xi) );
    if ( isempty(m) ) continue; end
    xi(m) = nan;
    % Convert the depths into layers
    %dd=obs.z(m);[dd,ind]=sort(dd,'descending');
    nz(m) = interp1( opt.z(:,y((l(i))),x(l(i))), layer, obs.z(m) );
    
    % Next, check for unique times and average together any points that
    % wind up in the same grid cell
    for t=transpose(unique(obs.time(m))),
      n = find( obs.time(m) == t );
      [u,v,s] = unique( floor(nz(m(n))) );
      for u=1:max(s),
        p=find(s==u);
        if (length(p)==1) continue; end
        for v=1:length(opt.vars),
          eval(sprintf('obs.%s(m(n(p))) = [nanmean(obs.%s(m(n(p)))) ones(1,length(p)-1)*nan];', ...
            char(opt.vars(v)), char(opt.vars(v))));
          eval(sprintf('obs.%s_v(m(n(p))) = [nanmean(obs.%s_v(m(n(p)))) ones(1,length(p)-1)*nan];', ...
            char(opt.vars(v)), char(opt.vars(v))));
          nz(m(n(p))) = [nanmean(nz(m(n(p)))) ones(1,length(p)-1)*nan];
        end
      end
    end
  end
end
nz(nz>layer(end)-1)=layer(end)-1;
