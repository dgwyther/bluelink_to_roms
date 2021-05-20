function extrfield = oainterp(londata,latdata,data,lon,lat,ro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function extrfield = oainterp(londata,latdata,data,lon,lat,ro)
%
% pierrick 2001 - derived from the fortran programs of 
% Alain Colin de Verdiere (2000)
%
% compute an objective analysis on a scalar field.
%
%   input: 
%  londata   : longitude of data points (vector)
%  latdata   : latitude of data points (vector)
%  data      : values of the data points (vector)
%  lon       : longitude of the estimated points (vector)
%  lat       : latitude of the estimated points (vector)
%  ro        : decorrelation scale
%
%   output:
%  extrfield : estimated values (vector)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 5
  error('Not enough input arguments')
elseif nargin < 6
  disp('using default decorrelation scale:  ro = 500 km')
  ro = 5e5;
end
%
mdata=mean(data);
data=data-mdata;
invro=1/ro;
i=[1:1:length(londata)];
j=[1:1:length(lon)];
[I,J]=meshgrid(i,i);
r1=spheric_dist(latdata(I),latdata(J),londata(I),londata(J));
%
[I,J]=meshgrid(i,j);
r2=spheric_dist(lat(J),latdata(I),lon(J),londata(I));
%
extrfield=mdata+(exp(-r2*invro)/exp(-r1*invro))*data;
%
return

