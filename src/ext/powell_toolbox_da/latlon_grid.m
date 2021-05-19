function [Xgrid,Ygrid]=latlon_grid(gname,obslon,obslat,Ccorrection);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [Xgrid,Ygrid]=obs_ijpos(gname,obslon,obslat)                     %
%                                                                           %
% This function computes the fractional (I,J) model RHO-grid locations      %
% at the observations (obslon,obslat) locations.                            %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       NetCDF grid file name (character string).                  %
%    obslon      Observation longitude (positive, degrees_east).            %
%    obslat      Observation latitude (positive, degrees_north).            %
%    Ccorrection Small correction for curvilinear grids (0: no, 1: yes).    %
%                                                                           %
% On Ouput:                                                                 %
%                                                                           %
%    Xgrid       Model fractional X-grid locations at RHO-points.           %
%    Ygrid       Model fractional Y-grid locations at RHO-points.           %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If appropriate, transpose input vectors so they are of size: [length 1].

lsize=size(obslon);
if (lsize(1) < lsize(2)),
  obslon=obslon';
end,

lsize=size(obslat);
if (lsize(1) < lsize(2)),
  obslat=obslat';
end,

if (nargin < 4),
  Ccorrection=0;
end,

%----------------------------------------------------------------------------
% Read in model grid variables.
%----------------------------------------------------------------------------

[vname,nvars]=nc_vname(gname);

got.spherical=0;
got.angle=0;
got.mask_rho=0;
got.lon_rho=0;
got.lat_rho=0;

for n=1:nvars
  name=deblank(vname(n,:));
  switch name
    case 'spherical'
      got.spherical=1;
    case 'lon_rho'
      got.lon_rho=1;
    case 'lat_rho'
      got.lat_rho=1;
    case 'angle'
      got.angle=1;
    case 'mask_rho'
      got.mask_rho=1;
  end,
end,

if (got.spherical),
  spherical=nc_varget(gname,'spherical');
  if (spherical == 'T' | spherical == 't'),
    spherical=1;
  else,
    spherical=0;
  end,
else,
  spherical=1;
end,

if (got.lon_rho),
  rmask=permute(nc_varget(gname,'mask_rho'),[2 1]);
  rlon=permute(nc_varget(gname,'lon_rho'),[2 1]);
else,
  error(['OBS_IJPOS - cannot find variable: lon_rho']);
end,

if (got.lat_rho),
  rlat=permute(nc_varget(gname,'lat_rho'),[2 1]);
else,
  error(['OBS_IJPOS - cannot find variable: lat_rho']);
end,

if (got.angle),
  angle=permute(nc_varget(gname,'angle'),[2 1]);
else
  angle=zeros(size(rlon));
end,

if (got.mask_rho),
  rmask=permute(nc_varget(gname,'mask_rho'),[2 1]);
else
  rmask=ones(size(rlon));
end,

%----------------------------------------------------------------------------
%  Extract polygon defining application grid box.
%----------------------------------------------------------------------------

[Im,Jm]=size(rlon);


Xbox=[squeeze(rlon(:,1)); ...
      squeeze(rlon(Im,2:Jm))'; ...
      squeeze(flipud(rlon(1:Im-1,Jm))); ...
      squeeze(fliplr(rlon(1,1:Jm-1)))'];

Ybox=[squeeze(rlat(:,1)); ...
      squeeze(rlat(Im,2:Jm))'; ...
      squeeze(flipud(rlat(1:Im-1,Jm))); ...
      squeeze(fliplr(rlat(1,1:Jm-1)))'];

% CAE change to not use inside.m, but rather use inpolygon.m (available
%            in the standard matlab distribution).

[in on]=inpolygon(obslon,obslat,Xbox,Ybox);
out=find(~in & ~on);

good=ones(1,length(obslon));totlength=length(good);
good(out)=[];

obslon(out)=[];
obslat(out)=[];

%  Set complex vector of points outlining polygon.

% Zbox=complex(Xbox,Ybox);

%  Check if requested observation locations are inside/outside of the
%  outlining polygon.

% for i=1:length(obslon);
%  p=complex(obslon(i),obslat(i));
%  k=inside(p,Zbox);
%   if isempty(k),
%     in(i)=NaN;
%   else,
%     in(i)=k;
%   end,
% end,
% out=find(isnan(in));

%plot(Xbox,Ybox,'r-',obslon,obslat,'b+');

%pcolor(rlon,rlat,rmask);
%shading flat;
%hold on;
%plot(obslon,obslat,'b+');
%hold off;

%----------------------------------------------------------------------------
% Compute model grid fractional (I,J) locations at observation locations
% via interpolation.
%----------------------------------------------------------------------------

Igrid=repmat([0:1:Im-1]',[1 Jm]);
Jgrid=repmat([0:1:Jm-1] ,[Im 1]); 

Xgrid=griddata(rlon(1:Im-1,1:Jm-1),rlat(1:Im-1,1:Jm-1),Igrid(1:Im-1,1:Jm-1),obslon,obslat,'nearest');
Ygrid=griddata(rlon(1:Im-1,1:Jm-1),rlat(1:Im-1,1:Jm-1),Jgrid(1:Im-1,1:Jm-1),obslon,obslat,'nearest');

% disp('here, DEG made a change: excluded the last row and column, and did a NN interp')

%----------------------------------------------------------------------------
% Curvilinear corrections.
%----------------------------------------------------------------------------

if (Ccorrection),

  Eradius=6371315.0;                % meters
  deg2rad=pi/180;                   % degrees to radians factor

  I=fix(Xgrid)+1;                   % need to add 1 because zero lower bound
  J=fix(Ygrid)+1;                   % need to add 1 because zero lower bound

% Knowing the correct cell, calculate the exact indices, accounting
% for a possibly rotated grid.  Convert all positions to meters first.

  yfac=Eradius.*deg2rad;
  xfac=yfac.*cos(obslat.*deg2rad);

  xpp=(obslon-diag(rlon(I,J))).*xfac;
  ypp=(obslat-diag(rlat(I,J))).*yfac;

% Use Law of Cosines to get cell parallelogram "shear" angle.

  diag2=(diag(rlon(I+1,J))-diag(rlon(I,J+1))).^2+ ...
        (diag(rlat(I+1,J))-diag(rlat(I,J+1))).^2;

  aa2=(diag(rlon(I,J))-diag(rlon(I+1,J))).^2+ ...
      (diag(rlat(I,J))-diag(rlat(I+1,J))).^2;

  bb2=(diag(rlon(I,J))-diag(rlon(I,J+1))).^2+ ...
      (diag(rlat(I,J))-diag(rlat(I,J+1))).^2;

  phi=asin((diag2-aa2-bb2)./(2.*sqrt(aa2.*bb2)));

% Transform fractional locations into curvilinear coordinates. Assume the
% cell is rectanglar, for now.

  dx=xpp.*cos(diag(angle(I,J))+ypp.*sin(diag(angle(I,J))));
  dy=ypp.*cos(diag(angle(I,J))-xpp.*sin(diag(angle(I,J))));

% Correct for parallelogram.

  dx=dx+dy.*tan(phi);
  dy=dy./cos(phi);

% Scale with cell side lengths to translate into cell indices.

  dx=dx./sqrt(aa2)./xfac;

  ind=find(dx < 0); if (~isempty(ind)), dx(ind)=0; end,
  ind=find(dx > 1); if (~isempty(ind)), dx(ind)=1; end,

  dy=dy./sqrt(bb2)./yfac;

  ind=find(dy < 0); if (~isempty(ind)), dy(ind)=0; end,
  ind=find(dy > 1); if (~isempty(ind)), dy(ind)=1; end,

  Xgrid=fix(Xgrid)+dx;
  Ygrid=fix(Ygrid)+dy;

end,

%----------------------------------------------------------------------------
% Mark outlier obsvations.
%----------------------------------------------------------------------------

% these actuallly need to be taken out earlier for the Ccorrection to work, then put back in as NaNs
if (~isempty(out));
 % Xgrid(out)=NaN;
 % Ygrid(out)=NaN;
XgridF=nan(1,totlength);XgridF(good)=Xgrid;
YgridF=nan(1,totlength);YgridF(good)=Ygrid;
Xgrid=XgridF';Ygrid=YgridF';
end,

return


