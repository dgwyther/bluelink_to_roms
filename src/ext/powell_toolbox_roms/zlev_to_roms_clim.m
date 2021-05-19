function zlev_to_roms_clim(zfile, outfile, zgrd, rgrd, averaging, period);

% zlev_to_roms_clim(zfile, outfile, zgrd, rgrd, averaging, period);
%
% Given a z-level history file, average together and put into a ROMS climatology
% file.

if nargin < 4
  error('you must specify arguments.')
end
if nargin < 5
  averaging=1;
end

% Load the basics
ht=nc_varget(zfile,'time');
epoch=get_epoch(zfile,'time');
lev=-nc_varget(zfile,'depth');
lev = ([0; lev(1:end-1)] + lev) .* 0.5; 

% Construct the time period averaging
del=floor(averaging/2);
time=[del+1:averaging:length(ht)-del];
if nargin == 6,
  period=period-epoch;
  l=find( ht >= period(1) & ht <= period(2) );
  if ( isempty(l) ) return; end
  time=[l(1)+del l(end)-del];
end

% First, create the climatology
disp(['create climatology file: ' outfile]);
unix([regexprep(which('clim_write'),'\.m$','\.sh') ' ' outfile ' '...
      num2str([rgrd.lp rgrd.mp rgrd.n length(time)])]);

% Variables to construct
vars={'zeta' 'u' 'v' 'temp' 'salt'};
tvars={'zeta_time' 'v2d_time' 'v3d_time' 'temp_time' 'salt_time'};
ndims=[2 3 3 3 3];
grid={'r' 'u' 'v' 'r' 'r'};
 
% Convert everything to x,y coordinates
[hx,hy,rxr,ryr]=grid_cartesian(zgrd,rgrd);
[tx,ty,rxu,ryu]=grid_cartesian(zgrd,rgrd,'r','u');
[tx,ty,rxv,ryv]=grid_cartesian(zgrd,rgrd,'r','v');

% Save the time records
for v=1:length(tvars),
  nc_varput(outfile,char(tvars(v)),ht(time));
end

% Set up the arrays
minpts = 0.1*numel(zgrd.maskr);
hwet = find(zgrd.maskr==1);
hlon = zgrd.lonr;
hlat = zgrd.latr;
rwetr = find(rgrd.maskr==1);
rwetu = find(rgrd.masku==1);
rwetv = find(rgrd.maskv==1);
[zr,zwr,hzr]=grid_depth(rgrd);
[zu,zwu,hzu]=grid_depth(rgrd,'u');
[zv,zwv,hzv]=grid_depth(rgrd,'v');

% Go through each record, averaging and putting onto ROMS
progress(0,0,1);
for t=1:length(time),
  progress(length(time),t,1);
  clear stemp ssalt
  rec=[];
  for v=1:length(vars),
    var=char(vars(v));
    if (ndims(v)==2),
      if averaging>1,
        data=squeeze(nanmean(nc_varget(zfile,var,[time(t)-del-1 0 0], ...
                                         [averaging -1 -1])));
      else
        data=squeeze(nc_varget(zfile,var,[time(t)-del-1 0 0], ...
                                         [1 -1 -1]));
      end
      hwet=find(~isnan(data));
      ndata=zeros(size(rgrd.maskr));
      if ( length(hwet) > minpts )
        ndata(rwetr) = griddata(hx(hwet),hy(hwet),  ...
                                data(hwet),rxr(rwetr),ryr(rwetr));
      end
      nc_varput(outfile,var,reshape(ndata,[1 size(ndata)]),[t-1 0 0], ...
                                          [1 size(ndata)]);
    else
      if averaging>1,
        data=squeeze(nanmean(nc_varget(zfile,var,[time(t)-del-1 0 0 0], ...
                                         [averaging -1 -1 -1])));
      else                                         
        data=squeeze(nc_varget(zfile,var,[time(t)-del-1 0 0 0], ...
                                         [1 -1 -1 -1]));
      end
      ndata=zeros([length(lev) size(rxr)]);
      % Interpolate each horizontal z-level
      for d=1:length(lev),
        hwet=find(~isnan(data(d,:)));
        if ( length(hwet) > minpts )
          ndata(d,rwetr)=griddata(hx(hwet),hy(hwet),data(d,hwet), ...
                          rxr(rwetr),ryr(rwetr),'linear');
        end
      end
      ndata(isnan(ndata))=0;
      evalc(['rec.' var '=ndata']);
    end
  end
  % We have the density and velocity fields, but they need to be converted
  % to the ROMS angle and s-levels. First the density.
  [temp,salt]=interp_density(rec.temp,rec.salt,lev,rgrd);
  nc_varput(outfile,'temp',temp,[t-1 0 0 0],[1 size(temp)]);
  nc_varput(outfile,'salt',salt,[t-1 0 0 0],[1 size(salt)]);
  % Next, rotate the velocities, put back onto their proper grids,
  % vertically interpolate, then create ubar and vbar
  rotmat=repmat(reshape(rgrd.angle,[1 size(rgrd.angle)]),[length(lev) 1 1]);
  u=rec.u.*cos(rotmat) + rec.v.*sin(rotmat);
  v=rec.v.*cos(rotmat) - rec.u.*sin(rotmat);
  ru=zeros(size(zr));
  rv=zeros(size(zr));
  % Convert to s-levels
  for c=1:length(rwetr),
    i=rwetr(c);
    nu=u(:,i);
    nv=v(:,i);
    i1 = find(-diff([0;lev]) > 0.01 & nu ~= 0 &  ...
                -diff([0;lev]) > 0.01 & nv ~= 0);
    if (isempty(i1)) continue; end
    nl=lev(i1); 
    nu=nu(i1);
    nv=nv(i1);
    if ( nl(end) < -4000 ) 
      nu(end)=nanmean(nu(end-1:end));
      nv(end)=nanmean(nv(end-1:end));
    end
    nl = [0.; nl; zr(1,i)-1000];
    nu = [nu(1); nu; nu(end)*0.1];
    nv = [nv(1); nv; nv(end)*0.1];
    ru(:,i) = interp1(nl,nu,zr(:,i),'linear');
    rv(:,i) = interp1(nl,nv,zr(:,i),'linear');
  end
  % Put onto u and v grids
  ru=0.5*(ru(:,:,1:end-1)+ru(:,:,2:end));
  rv=0.5*(rv(:,1:end-1,:)+rv(:,2:end,:));
  nc_varput(outfile,'u',reshape(ru,[1 size(ru)]),[t-1 0 0 0], [1 size(ru)]);
  nc_varput(outfile,'v',reshape(rv,[1 size(rv)]),[t-1 0 0 0], [1 size(rv)]);
  % Create ubar and vbar
  bar = sum( hzu .* ru, 1 ) ./ sum( hzu, 1 );
  nc_varput(outfile,'ubar',bar,[t-1 0 0], [size(bar)]);
  bar = sum( hzv .* rv, 1 ) ./ sum( hzv, 1 );
  nc_varput(outfile,'vbar',bar,[t-1 0 0], [size(bar)]);
end
