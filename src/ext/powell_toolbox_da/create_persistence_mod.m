function nlmod = create_persistence_mod( hisfile, obsfile )

% nlmod = create_persistence_mod( hisfile, obsfile )
%
% Given a history file, load the first record and compare
% it against the observations file, storing the results in
% the mod file. This allows a comparison of persistence

obs = obs_read( obsfile );

vars={ 'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt' };

nlmod = ones(size(obs.value))*nan;

for v=unique(obs.type)',
  disp(char(vars(v)));
  lo=find(obs.type==v);
  data = nc_varget(hisfile, char(vars(v)));
  if (ndims(data)==4)
    data = squeeze(data(1,:,:,:));
    [i,j,k]=meshgrid(0:size(data,3)-1,0:size(data,2)-1,1:size(data,1));
    for z=1:size(data,1),
      data(z,:,:)=convolve_land( data(z,:,:), squeeze(data(z,:,:)), 3);
    end
    nlmod(lo) = interp3(i,j,k,permute(data,[2 3 1]),obs.x(lo),obs.y(lo),obs.depth(lo));
  else
    data = squeeze(convolve_land( data(1,:,:), squeeze(data(1,:,:)), 3));
    [x,y]=meshgrid(0:size(data,2)-1,0:size(data,1)-1);
    nlmod(lo) = interp2(x,y,data,obs.x(lo),obs.y(lo));
  end
end


