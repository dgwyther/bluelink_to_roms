function zlev_to_roms_clim_BlueLink_EACgrid(zfile, outfile, zgrd, rgrd, averaging,period);

%zfile='BRAN2p1_his_20_26dec_2006.nc';
%outfile='BRAN2p1_clim_2006.nc';
%zgrd=grid_read('./EACouter_BL_grid.nc');
%rgrd=grid_read('../make_EAC_grid/EACouter_varres_grd.nc');
%averaging=1;%7;


% Given a z-level history file, average together and put into a ROMS climatology
% file.

% in this script we fix the N and S boundaries on the shelf where the EAC grid bathy cannot match BlueLink bathy, as it would give unreasonable PGEs

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
  time=[l(1)+del:l(end)-del+1];
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
      data=squeeze(nanmean_old(nc_varget(zfile,var,[time(t)-del-1 0 0], ...
                                         [averaging -1 -1])));
      %data=data(3:end-2,3:end-2);
      hwet=find(~isnan(data));
      ndata=zeros(size(rgrd.maskr));
      if ( length(hwet) > minpts )
        ndata(rwetr)=griddata(hx(hwet),hy(hwet),data(hwet),rxr(rwetr),ryr(rwetr));
      end
      nc_varput(outfile,var,reshape(ndata,[1 size(ndata)]),[t-1 0 0], ...
                                          [1 size(ndata)]);
    else
      data=squeeze(nanmean_old(nc_varget(zfile,var,[time(t)-del-1 0 0 0], ...
                                         [averaging -1 -1 -1])));
      %data=data(:,3:end-2,3:end-2);
      ndata=zeros([length(lev) size(rxr)]);
      % Interpolate each horizontal z-level
      dend=length(lev);
      for d=1:dend;
        hwet=find(~isnan(data(d,:)));
        if ( length(hwet) > minpts )
          ndata(d,rwetr)=griddata(hx(hwet),hy(hwet),data(d,hwet), ...
                          rxr(rwetr),ryr(rwetr),'linear');
        end
      end
      ndata(isnan(ndata))=0;
      evalc(['rec.' var '=ndata']);
    end % end ndims loop
  end % end length(vars) loop
  % We have the density and velocity fields, but they need to be converted
  % to the ROMS angle and s-levels. First the density.
  [temp,salt]=interp_density(rec.temp,rec.salt,lev,rgrd);
 
 for c=1:size(rgrd.maskr,1)
    for d=1:size(rgrd.maskr,2)

 if c>=300&d<=75 | c<=20&d<=106 % at nth and sth bry on shelf where bathy doesn't match BL
   % for depths in roms below BL ocean bottom, set T and S to profile offshore of shelf  
 % find the closest eastward point that is this depth or deeper in BL bathy and make the TS profile this  
    nt=temp(:,c,d);
    ns=salt(:,c,d);
    i1 = find(rec.temp(:,c,d) ~= 0 & rec.salt(:,c,d) ~= 0);
    if (isempty(i1)) continue; end
    nl=lev(i1);

    indb=find(zr(:,c,d)<nl(end));
    if isempty(indb);continue;end % if roms is shallow thatn BL we don't care, the interp works fine
    dd=d;
       bldepth=nl(end);
       while bldepth > zr(1,c,d) 
           dd=dd+1;
             if dd>272;dd=d;bldepth=zr(1,c,d)-100;continue;end
            i1 = find(rec.temp(:,c,dd) ~= 0 & rec.salt(:,c,dd) ~= 0);
            if (isempty(i1)) continue; end
            bldepth=lev(i1(end));
       end
       
     zz=zr(:,c,dd);T=temp(:,c,dd);S=salt(:,c,dd);
      
      ntn=interp1(zz,T,zr(:,c,d));if isnan(ntn(end));ntn(end)=ntn(end-1).*1.0001;end
      nsn=interp1(zz,S,zr(:,c,d));if isnan(nsn(end));nsn(end)=nsn(end-1);end

      ratio=[ones(1,12),[8/9:-1/9:1/9],zeros(1,10)]';
      ntnn=ratio.*ntn + (1-ratio).*nt;
      nsnn=ratio.*nsn + (1-ratio).*ns;

          in=find(isnan(ntnn));ins=find(isnan(nsnn));
      if ~isempty(in);ntnn(in)=ntnn(in(end)+1);end
      if ~isempty(ins);nsnn(ins)=nsnn(ins(end)+1);end

    temp(:,c,d)=ntnn;salt(:,c,d)=nsnn;

 end % end nth sth bry on shelf area loop
 end % end c loop
end % end d loop
%figure;pcolor(g.lonr(1,:),squeeze(zr(:,1,:)),squeeze(temp(:,1,:)));shading flat;colorbar

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
  for c=1:size(rgrd.maskr,1)
    for d=1:size(rgrd.maskr,2)
    nu=u(:,c,d);
    nv=v(:,c,d);
    i1 = find(nu ~= 0 & nv ~= 0);
    if (isempty(i1)) continue; end
    nl=lev(i1); 
    nu=nu(i1);
    nv=nv(i1);
    if ( nl(end) < -4000 ) 
      nu(end)=nanmean_old(nu(end-1:end));
      nv(end)=nanmean_old(nv(end-1:end));
    end

%if (nl(1)<0)&(zr(1,c,d)>=-200)
%    nl = [0; nl;-200];
%    nu = [nu(1); nu;nu(end)*0.1];
%    nv = [nv(1); nv;nv(end)*0.1];
%elseif (nl(1)==0)&zr(1,c,d)>=-200
%    nl = [nl;-200];
%    nu = [nu;nu(end)*0.1];
%    nv = [nv;nv(end)*0.1];
%elseif nl(1)<0
%    nl = [0; nl; zr(1,c,d)-1000];
%    nu = [nu(1); nu; nu(end)*0.1];
%    nv = [nv(1); nv; nv(end)*0.1];
%elseif nl(1)==0
%    nl = [nl; zr(1,c,d)-1000];
%    nu = [nu; nu(end)*0.1];
%    nv = [nv; nv(end)*0.1];
%
%end
    ru(:,c,d) = interp1(flipud(nl),flipud(nu),zr(:,c,d),'pchip',NaN);
     rv(:,c,d) = interp1(flipud(nl),flipud(nv),zr(:,c,d),'pchip',NaN);


un=find(isnan(ru(:,c,d)));
if ~isempty(un)
ii=find(diff(un)>1);
if ~isempty(ii)
unbot=un(1:ii);unsurf=un(ii+1:end);
else
 if un(end)==30;unsurf=un;unbot=[];elseif un(1)==1;unbot=un;unsurf=[];end
end
else
unsurf=[];unbot=[];
end

vn=find(isnan(rv(:,c,d)));
if ~isempty(vn)
ii=find(diff(vn)>1);
if ~isempty(ii)
vnbot=vn(1:ii);vnsurf=vn(ii+1:end);clear ii
else
 if vn(end)==30;vnsurf=vn;vnbot=[];elseif vn(1)==1;vnbot=vn;vnsurf=[];end
end
else
vnsurf=[];vnbot=[];
end

if ~isempty(unsurf);ru(unsurf,c,d)=ru(unsurf(1)-1,c,d);end
if ~isempty(vnsurf);rv(vnsurf,c,d)=rv(vnsurf(1)-1,c,d);end

if ~isempty(unbot);
 if zr(1,c,d)>-3500
% calc bl volume
dd=-([nl(1);diff(nl)]);
vbu=sum(dd.*nu);

% calc vol for roms depths above BL bottom
ddr=([diff(squeeze(zwr(unbot(end)+1:end,c,d)))]);
vru=sum(ddr.*ru(unbot(end)+1:end,c,d));

% now include the volume difference in the lower layers ie. unbot depths
ddrb=-zwr(1,c,d)-sum(ddr);% depth to bottom of roms from bottom of bl
dabovebottom=-zwr(1,c,d)+zr(unbot,c,d);
diffrb=diff(zwr(unbot(1):unbot(end)+1,c,d));
vdiffu=vbu-vru;
shape=(1.*dabovebottom)./sum(dabovebottom);% distribute weighted by depth above bottom
volu=vdiffu.*shape;
rudeepdistributed=volu./diffrb;
ru(unbot,c,d)=rudeepdistributed;
 else
ru(unbot,c,d)=0.1*ru(unbot(end)+1,c,d);
 end
end

if ~isempty(vnbot)
 if zr(1,c,d)>-3500
% calc bl volume
dd=-([nl(1);diff(nl)]);
vbv=sum(dd.*nv);

% calc vol for roms depths above BL bottom
ddr=([diff(squeeze(zwr(unbot(end)+1:end,c,d)))]);
vrv=sum(ddr.*rv(unbot(end)+1:end,c,d));

% now include the volume difference in the lower layers ie. unbot depths
ddrb=-zwr(1,c,d)-sum(ddr);% depth to bottom of roms from bottom of bl
dabovebottom=-zwr(1,c,d)+zr(unbot,c,d);
diffrb=diff(zwr(unbot(1):unbot(end)+1,c,d));

vdiffv=vbv-vrv;
volv=vdiffv.*shape;
rvdeepdistributed=volv./diffrb;
rv(unbot,c,d)=rvdeepdistributed;
  else
rv(vnbot,c,d)=0.1*rv(vnbot(end)+1,c,d);
 end
end
clear unbot vnbot unsurf vnsurf un vn

%if c>=300&d<=75 | c<=20&d<=106 % at nth and sth bry on shelf where bathy doesn't match BL
%indb=find(zr(:,c,d)<nl(end));
% if ~isempty(indb)
%inda=find(zr(:,c,d)>=nl(end));
%% calc bl volume
%dd=-([nl(1);diff(nl)]);
%vbu=sum(dd.*nu);
%vbv=sum(dd.*nv);
%
%% calc roms volume for inda depths
%if length(inda==1)
%
%ru(inda,c,d)=ru(inda,c,d).*0.8;
%rv(inda,c,d)=rv(inda,c,d).*0.8;
%
%elseif length(inda>1)
%ru(inda(2),c,d)=ru(inda(2),c,d).*0.6;
%ru(inda(1),c,d)=ru(inda(1),c,d).*0.3;
%
%rv(inda(2),c,d)=rv(inda(2),c,d).*0.6;
%rv(inda(1),c,d)=rv(inda(1),c,d).*0.3;
%
%end
%
%ddr=([diff(squeeze(zr(inda,c,d)))-zr(inda(end),c,d)]);
%vru=sum(ddr.*ru(inda,c,d));
%vrv=sum(ddr.*rv(inda,c,d));
%
%% now include the volume difference in the lower layers ie. indb depths
%ddrb=-zwr(1,c,d)-sum(ddr);
%dabovebottom=-zwr(1,c,d)+zr(indb,c,d);
%diffrb=diff(zwr(indb(1):indb(end)+1,c,d));
%
%vdiffu=vbu-vru;
%%rudeep=vdiffu./ddrb;
%%ru(indb,c,d)=rudeep;
%shape=(1.*dabovebottom)./sum(dabovebottom);% distribute weighted by depth above bottom
%volu=vdiffu.*shape;
%rudeepdistributed=volu./diffrb;
%ru(indb,c,d)=rudeepdistributed;
%
%vdiffv=vbv-vrv;
%%rvdeep=vdiffv./ddrb;
%%rv(indb,c,d)=rvdeep;
%volv=vdiffv.*shape;
%rvdeepdistributed=volv./diffrb;
%rv(indb,c,d)=rvdeepdistributed;
% end % ends if not empty indb loop
%end % ends the nth and sth bry on shelf fixing up loop - DELETE THIS LOOP AS NOT USED

    end % end c loop
  end % end d loop
  % Put onto u and v grids
  ru=0.5*(ru(:,:,1:end-1)+ru(:,:,2:end));
  rv=0.5*(rv(:,1:end-1,:)+rv(:,2:end,:));
%  nanmean(ru(15,100,100)) %DEG
  nc_varput(outfile,'u',reshape(ru,[1 size(ru)]),[t-1 0 0 0], [1 size(ru)]);
  nc_varput(outfile,'v',reshape(rv,[1 size(rv)]),[t-1 0 0 0], [1 size(rv)]);
  % Create ubar and vbar
  bar = sum( hzu .* ru, 1 ) ./ sum( hzu, 1 );
  nc_varput(outfile,'ubar',bar,[t-1 0 0], [size(bar)]);
  bar = sum( hzv .* rv, 1 ) ./ sum( hzv, 1 );
  nc_varput(outfile,'vbar',bar,[t-1 0 0], [size(bar)]);
end % end time loop
