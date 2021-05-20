function [type,vlevout]=get_type(fname,vname,vlevin);
%clear all
%close all
%fname='../Run/med_his.nc'
%vname='temp'
% get the type of a ROMS variable
% u,v,w,r
%
vlevout=vlevin;
type='r';
nc=netcdf(fname,'nowrite');
if isempty(nc)
  type='';
  return
end
var=nc{vname};
if isempty(var)
  type='';
  return
end
names=ncnames(dim(var));
ndim=length(names);
close(nc)
if ndim==1 
  type='';
  return
end

i=1;
name=char(names(i));
lname=length(name);
if name(lname-3:lname)~='time'
  disp('warning no time dependent')
else
  i=i+1;
end
name=char(names(i));
if name(1)=='s'
  l=length(name);
  if name(l)=='w'
    type='w';
    return
  else    
    i=i+1;
  end
else
  vlevout=0;
end
name=char(names(i));
if name(1)~='e' 
  type='';
  return
else
  l=length(name);
  if name(l)=='v'
    type='v';
    return
  end
end
name=char(names(i+1));
if name(1)~='x'
  type='';
  return
else
  l=length(name);
  if name(l)=='u'
    type='u';
    return
  end
end
return
