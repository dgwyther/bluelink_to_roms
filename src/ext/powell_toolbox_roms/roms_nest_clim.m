function roms_nest_clim(parent_grid,child_grid,parent_file,child_file, ...
                        freq,latres,lonres,convolve_scale)

% roms_nest_clim(parent_grid,child_grid,parent_file,child_file,freq)
% 
% Create an inner nest climatology file from a larger ROMS grid
%
% The lat_res is the length-scale in the latitudinal direction to use for interp
% lon_res is in meridional. convolve_scale is the number of convolution points to
% blend over land to mesh the grids.
%

if nargin<4
  error('you must specify all arguments');
end
if nargin<5
  freq=1;
end
if nargin<6
  latres=3/mean(parent_grid.pn(:))/110000;
  lonres=3/mean(parent_grid.pm(:))/110000;
  convolve_scale=5;
end

parent_name=regexprep(regexprep(regexprep(parent_grid.filename,'.*/',''),'\.nc',''), ...
                  '(roms|grid)[-_]*','');
child_name=regexprep(regexprep(regexprep(child_grid.filename,'.*/',''),'\.nc',''), ...
                  '(roms|grid)[-_]*','');
landmask=parent_grid.maskr;
landmask(landmask==0)=nan;

% Next, create the intermediate grid and pmap
pmapname=[parent_name '-' child_name '_pmap.mat'];
if ( ~exist(pmapname,'file'))
  disp('Generate PMAP');
  nest_weight_matrix(parent_grid,child_grid,10)
else
  evalc(['load ' pmapname]);
end

keyboard
% Create the output file
time=nc_varget(parent_file,'ocean_time')/86400;
tvec=floor(linspace(1,length(time),round(length(time)/freq)));
time=time(tvec);
disp(['create climatology file: ' child_file]);
unix([regexprep(which('clim_write'),'\.m$','\.sh') ' ' child_file ' '...
      num2str([child_grid.lp child_grid.mp child_grid.n length(time)])]);
tvars={'zeta_time' 'v2d_time' 'v3d_time' 'temp_time' 'salt_time'};

% Save the time records
for v=1:length(tvars),
  nc_varput(child_file,char(tvars(v)),time);
end

progress(0,0,1);
for t=1:length(tvec),
  progress(length(tvec),t,1);


  % Create the free surface
  zeta=squeeze(nc_varget(parent_file,'zeta',[tvec(t)-1 0 0],[1 -1 -1]));
  zeta=squeeze(convolve_land(zeta,parent_grid.maskr,convolve_scale));
  nzeta=ctranspose(rnt_oa2d(parent_grid.lonr',parent_grid.latr',zeta', ...
                            child_grid.lonr',child_grid.latr', ...
                            lonres,latres,pmapr)).*child_grid.maskr;
  nc_varput(child_file,'zeta',reshape(nzeta,[1 size(nzeta)]),[t-1 0 0], ...
                                        [1 size(nzeta)]);

  % Calculate the depths using the parent and child zeta, then add 
  % another layer to the input that is deeper than the deepest output,
  % we will replicate the data as well. This is to avoid any extrapolation
  [parent_grid.zr,zw]=grid_depth(parent_grid,'r',zeta);
  parent_grid.zr=permute([zw(1,:,:)-500; parent_grid.zr; zw(end,:,:)],[3 2 1]);
  [parent_grid.zu,zw]=grid_depth(parent_grid,'u',0.5*(zeta(:,2:end)+zeta(:,1:end-1)));
  parent_grid.zu=permute([zw(1,:,:)-500; parent_grid.zu; zw(end,:,:)],[3 2 1]);
  [parent_grid.zv,zw]=grid_depth(parent_grid,'v',0.5*(zeta(2:end,:)+zeta(1:end-1,:)));
  parent_grid.zv=permute([zw(1,:,:)-500; parent_grid.zv; zw(end,:,:)],[3 2 1]);
  [child_grid.zr,zw]=grid_depth(child_grid,'r',nzeta);
  [child_grid.zu,zw,child_grid.hzu]=grid_depth(child_grid,'u',0.5*(nzeta(:,2:end)+nzeta(:,1:end-1)));
  [child_grid.zv,zw,child_grid.hzv]=grid_depth(child_grid,'v',0.5*(nzeta(2:end,:)+nzeta(1:end-1,:)));
  child_grid.zr=permute(child_grid.zr,[3 2 1]);
  child_grid.zu=permute(child_grid.zu,[3 2 1]);
  child_grid.zv=permute(child_grid.zv,[3 2 1]);

  % Do the tracer variables
  vars={'temp' 'salt'};
  scale=[0.95 1];
  resscale=[1.25 3];
  for v=1:length(vars),
    var=char(vars(v));

    data=squeeze(nc_varget(parent_file,var,[tvec(t)-1 0 0 0],[1 -1 -1 -1]));
    data=[data(1,:,:)*scale(v); data; data(end,:,:)];
    for k=1:size(data,1),
      data(k,:,:)=convolve_land(squeeze(data(k,:,:)), parent_grid.maskr,  ...
                                convolve_scale);
    end
    data=permute(data,[3 2 1]);
    ndata=rnt_oa3d_bdc(parent_grid.lonr', parent_grid.latr', parent_grid.zr,  ...
                       data, child_grid.lonr', child_grid.latr', child_grid.zr, ...
                       resscale(v)*lonres, resscale(v)*latres, pmapr);
    ndata=permute(ndata,[3 2 1]);
    ndata=ndata.*repmat(reshape(child_grid.maskr,[1 size(child_grid.maskr)]), ...
                                [size(ndata,1) 1]);
    ndata(isnan(ndata))=0;
    nc_varput(child_file,var,reshape(ndata,[1 size(ndata)]),[t-1 0 0 0], ...
                                        [1 size(ndata)]);
  end

  % Interpolate the u and v fields onto the new rho-grid, rotate
  % then transform to u and v grids.
  u=squeeze(nc_varget(parent_file,'u',[tvec(t)-1 0 0 0],[1 -1 -1 -1]));
  u=[u(1,:,:)*0.1; u; u(end,:,:)];
  for k=1:size(u,1),
    u(k,:,:)=convolve_land(squeeze(u(k,:,:)), parent_grid.masku,  ...
                              convolve_scale);
  end
  v=squeeze(nc_varget(parent_file,'v',[tvec(t)-1 0 0 0],[1 -1 -1 -1]));
  v=[v(1,:,:)*0.1; v; v(end,:,:)];
  for k=1:size(v,1),
    v(k,:,:)=convolve_land(squeeze(v(k,:,:)), parent_grid.maskv,  ...
                              convolve_scale);
  end
  nu=zeros([size(parent_grid.maskr') size(u,1)]);
  nv=nu;
  nu(2:end,:,:)=permute(u,[3 2 1]);
  nv(:,2:end,:)=permute(v,[3 2 1]);
  [nu,nv]=rnt_rotate(nu,nv,-(parent_grid.angle'));
  % Put onto new grid
  u=zeros([size(child_grid.maskr') child_grid.n]);
  v=u;
  u(2:end,:,:)=rnt_oa3d_bdc(parent_grid.lonu',  ...
                  parent_grid.latu',  ...
                  parent_grid.zu,  ...
                  nu(2:end,:,:), child_grid.lonu',  ...
                  child_grid.latu', child_grid.zu, ...
                  lonres, latres, pmapu);
  v(:,2:end,:)=rnt_oa3d_bdc(parent_grid.lonv',  ...
                  parent_grid.latv',  ...
                  parent_grid.zv,  ...
                  nv(:,2:end,:), child_grid.lonv',  ...
                  child_grid.latv', child_grid.zv, ...
                  lonres, latres, pmapv);
  u(1,:,:)=u(2,:,:);
  v(:,1,:)=v(:,2,:);
  [u,v]=rnt_rotate(u,v,child_grid.angle');
  u=permute(u(2:end,:,:),[3 2 1]);
  u(isnan(u))=0;
  v=permute(v(:,2:end,:),[3 2 1]);
  v(isnan(v))=0;
  nc_varput(child_file,'u',reshape(u,[1 size(u)]),[t-1 0 0 0], ...
                                     [1 size(u)]);
  nc_varput(child_file,'v',reshape(v,[1 size(v)]),[t-1 0 0 0], ...
                                     [1 size(v)]);

  % Create ubar and vbar
  bar = sum(child_grid.hzu .* u, 1) ./ sum(child_grid.hzu, 1);
  nc_varput(child_file,'ubar',bar,[t-1 0 0], size(bar));
  bar = sum(child_grid.hzv .* v, 1) ./ sum(child_grid.hzv, 1);
  nc_varput(child_file,'vbar',bar,[t-1 0 0], size(bar));
end
