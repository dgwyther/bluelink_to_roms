function [srcx,srcy,newx,newy]=grid_cartesian(srcgrid,newgrid,varargin)
  
% [srcx,srcy,newx,newy]=grid_cartesian(srcgrid,newgrid)
%
% Given two gridfiles, put them onto the same curvilinear distance coordinate
% for horizontal interpolation.

srct='r';
newt='r';
if nargin==3
  srct=varargin{1};
end
if nargin==4
  newt=varargin{2};
end

switch srct
  case 'u'
    slat=srcgrid.latu;
    slon=srcgrid.lonu;
  case 'v'
    slat=srcgrid.latv;
    slon=srcgrid.lonv;
  otherwise
    slat=srcgrid.latr;
    slon=srcgrid.lonr;
end
switch newt
  case 'u'
    nlat=newgrid.latu;
    nlon=newgrid.lonu;
  case 'v'
    nlat=newgrid.latv;
    nlon=newgrid.lonv;
  otherwise
    nlat=newgrid.latr;
    nlon=newgrid.lonr;
end

minlat=min([min(slat(:)) min(nlat(:))])-1;
minlon=min([min(slon(:)) min(nlon(:))])-1;

% First, the srcgrid
olon=ones(size(slon))*minlon;
olat=ones(size(slat))*minlat;
srcx=earth_distance(olon, slon, slat, slat)*1000;
srcy=earth_distance(slon, slon, olat, slat)*1000;
% srcx=spheriq_dist(olon,slat,slon,slat);
% srcy=spheriq_dist(slon,olat,slon,slat);

% Next, the newgrid
olon=ones(size(nlon))*minlon;
olat=ones(size(nlat))*minlat;
newx=earth_distance(olon, nlon, nlat, nlat)*1000;
newy=earth_distance(nlon, nlon, olat, nlat)*1000;
% newx=spheriq_dist(olon,nlat,nlon,nlat);
% newy=spheriq_dist(nlon,olat,nlon,nlat);


