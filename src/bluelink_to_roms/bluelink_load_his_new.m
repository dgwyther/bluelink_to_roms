
% LOAD BRAN DATA HISTORY GIVEN A ROMS GRID FILE
% Created by Colette Kerry on 2014-08-12
% modified for new bluelink files Sept 2015

addpath(genpath('../ext/'))
addpath(genpath('../../conf/'))

set_default_options()

%% ------ user input ------

grid=grid_read(opt.grid_path) % grid file path
epoch_roms=opt.epoch_roms;				% epoch for data
outpath=opt.outpath;	% set output path
outfile=opt.outfile; 	% set output file name
years=opt.years;	% set time coverage
path=opt.path;		% set path to BRAN2020 data

%% ----- end user input ------

vars={'zeta' 'u' 'v' 'temp' 'salt'};
dims=[3 4 4 4 4];
blvars={'eta' 'u' 'v' 'temp' 'salt'};
blvarsfile={'eta_t' 'u' 'v' 'temp' 'salt'};
grd={'r','u','v','r','r'};

m=repmat((1:12)',length(years),1);
y=[];
for ly=1:length(years)
yy=repmat(years(ly),12,1);
y=[y;yy];
end

% daily data
time=[datenum(years(1),1,1):datenum(years(end),12,31)]+0.5;

  for lbt=1:length(y)

   m_s=num2str(m(lbt)); if length(m_s)<2; m_s=['0',m_s]; end
   
     for vv=1:length(blvars)
     tic

    file =[path,'ocean_',blvarsfile{vv},'_',num2str(y(lbt)),'_',m_s,'.nc'];
 
     % Grab the region of interest and make the history file 
     if lbt==1&vv==1 % only do this once

bllat=nc_varget(file,'yt_ocean');
bllon=nc_varget(file,'xt_ocean');
%l=find(hycomlon>360);
%hycomlon(l)=hycomlon(l)-hycomlon(1);

ind=4;% this has to be the temp var, hard coded, sorry!
file_d =[path,'ocean_',blvarsfile{ind},'_',num2str(y(lbt)),'_',m_s,'.nc'];
bldepth=nc_varget(file_d,'st_ocean');

% also get the velocity grid points, also hard coded (u and v are on the same grid)
file_u =[path,'ocean_',blvarsfile{2},'_',num2str(y(lbt)),'_',m_s,'.nc'];
bllatu=nc_varget(file_u,'yu_ocean');
bllonu=nc_varget(file_u,'xu_ocean');

%% Are we crossing Greenwich?
%gwhich=[];
%if ( min(grid.lonr(:))<0 & max(grid.lonr(:))>0 )
%  gwhich=find(grid.lonr<0);
%  grid.lonr(gwhich)=grid.lonr(gwhich)+360;
%end
%% See if our grid uses + or - longitudes
%if ( ~isempty(find(grid.lonr<0)) )
%  l=find(hycomlon>180);
%  hycomlon(l)=hycomlon(l)-360;
%end

% get 0.2 degree either side

lon_list = find( bllon >= min(grid.lonr(:))-0.2 & ...
                 bllon <= max(grid.lonr(:))+0.2 );
lat_list = find( bllat >= min(grid.latr(:)-0.2) & ...)
                 bllat <= max(grid.latr(:))+0.2 );
zgrid.lon = bllon(lon_list);
zgrid.lat = bllat(lat_list);
[slon,slat]=meshgrid(zgrid.lon,zgrid.lat);

% also get the u and v grid
ulon = bllonu(lon_list);
ulat = bllatu(lat_list);
[slonu,slatu]=meshgrid(ulon,ulat);

lon_list = [lon_list(1)-1 length(lon_list)];
lat_list = [lat_list(1)-1 length(lat_list)];
zgrid.time = time - epoch_roms;
zgrid.depth = bldepth;
%if ( ~isempty(gwhich) )
%  % We need to put everything into the new coordinate system
%  grid.lonr(gwhich)=grid.lonr(gwhich)-360;
%  l=find(slon>180);
%  slon(l)=slon(l)-360;
%  lnlist=find( slon(1,:) >= min(grid.lonr(:)) &  ...
%               slon(1,:) <= max(grid.lonr(:)) );
%  ltlist=find( slat(:,1) >= min(grid.latr(:)) &  ...
%               slat(:,1) <= max(grid.latr(:)) );
%  [nlon,i]=sort(slon(1,lnlist));
%  lnlist=lnlist(i);
%  [nlat,i]=sort(slat(ltlist,1));
%  ltlist=ltlist(i);
%  [slon,slat]=meshgrid(nlon,nlat);
%  zgrid.lon = nlon;
%  zgrid.lat = nlat;
%end

% First, create the history file
if (~exist(outfile,'file'))
  disp(['create history file: ' outfile]);
  zgrid_write(zgrid,outfile,epoch_roms);
  % Fill it with zeros
  rec.zeta = nan([1 size(slon)]);
  rec.u    = nan([1 length(bldepth) size(slon)]);
  rec.v    = nan([1 length(bldepth) size(slon)]);
  rec.temp = nan([1 length(bldepth) size(slon)]);
  rec.salt = nan([1 length(bldepth) size(slon)]);
 % progress(0,0,1);
 % for t=1:length(time),
 %   progress(length(time),t,1);
    rec.time=time-epoch_roms;
    nc_addnewrecs(outfile,rec,'time');
 % end
end

     end % end the loop that makes the history file

% now lets get the vars  
if vv==1
bltime=nc_varget(file,'Time')+datenum(1979,1,1,0,0,0);
timelist=find(time==bltime(1));
end

  var=char(vars(vv));
  svar=char(blvarsfile(vv));
  disp(svar);

 % % First, find all empty records
 % if ( dims(v) == 3 )
 %   curdat = nc_varget(hisfile,var);
 % else
 %   curdat = squeeze(nc_varget(hisfile,var,[0 0 0 0], [-1 1 -1 -1]));
 % end
 % curdat = reshape(curdat,[size(curdat,1) size(curdat,2)*size(curdat,3)]);
 % curdat = nanmean(curdat,2);
 % list = find(isnan(curdat) | curdat > 1e30);
 % if ( isempty(list) ) continue; end
  
  %progress(0,0,1);
  %for t=1:length(list),
  %  progress(length(list),t,1);
  %  try 
      if ( dims(vv) == 3 )
        bldat = nc_varget(file, svar, ...
                   [0 lat_list(1) lon_list(1)], ...
                   [-1 lat_list(2) lon_list(2)]);
      %  if ( ~isempty(gwhich) )
      %    sodadat=sodadat(:,ltlist,lnlist);
      %  end
        nc_varput(outfile,var,bldat,[timelist-1 0 0],size(bldat))
      else 
        bldat = nc_varget(file,svar, ...
                        [0 0 lat_list(1) lon_list(1)], ...
                        [-1 -1 lat_list(2) lon_list(2)]);
        %if ( ~isempty(gwhich) )
         % sodadat=sodadat(:,:,ltlist,lnlist);
        %end
          if grd{vv}=='u'|grd{vv}=='v'
                 bldat = nc_varget(file,svar, ...
                        [0 0 lat_list(1) lon_list(1)], ...
                        [-1 -1 lat_list(2) lon_list(2)]);
                   bldat_r=nan(size(bldat));
                for t=1:size(bldat,1)
                 for d=1:size(bldat,2)
                  bldat_r(t,d,:,:)=griddata(slonu,slatu,squeeze(bldat(t,d,:,:)),slon,slat);
                 end
                end
         nc_varput(outfile,var,bldat_r,[timelist-1 0 0 0],size(bldat_r))
         else % this is T and S
         nc_varput(outfile,var,bldat,[timelist-1 0 0 0],size(bldat))
         end % end if u grid loop
  %  catch
  %    fprintf(1,'X');
  %    continue;
    end % end if dims is 3 or 4 loop
        ttot=toc;
        fdone=['Done ocean_',blvars{vv},'_',num2str(y(lbt)),'_',m_s,'.nc ------ took ',num2str(ttot),' seconds'];
        if lbt==1&vv==1; fid = fopen('MLrunlog.log','w');end
        fprintf(fid,'%s\n',fdone);
  end % end the vv loop
end % end the time/number of files loop (lbt), one file per month
fclose(fid)
