function [day,month,year,thedate]=get_date(fname,tindex);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
% function [day,month,year,thedate]=getdate(fname,tindex);
%
% get the date from the time index of a ROMS netcdf file
%   (for a 360 days year)
%
% input:
%
%  fname    ROMS netcdf file name (average or history) (string)
%  tindex   time index (integer)
%
% output:
%
%  day      day (scalar)
%  month    month (string)
%  year     year (scalar)
%  thedate  date (string)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Month=[ 'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';...
'Sep';'Oct';'Nov';'Dec'];

nc=netcdf(fname);
time=nc{'scrum_time'}(tindex);
if (isempty(time))
  time=nc{'ocean_time'}(tindex);
end
if (isempty(time))
  year=0;
  mois=0;
  day=0;
  month='';
  thedate='';
  return
end
close(nc)

year=floor(1+time/(24*3600*360));

mois=floor(1+rem(time/(24*3600*30),12));

day=floor(1+rem(time/(24*3600),30));

month=Month(mois,:);

thedate=[num2str(day),' ',month,...
' of model year ',num2str(year)];

return
