function epoch = get_epoch( hisfile, time )
  
% from the history file, determine the epoch time

if nargin < 2
  time='ocean_time';
end

v=nc_getvarinfo(hisfile,time);

epoch=datenum(0,1,1);

for i=1:length(v.Attribute),
  if ( strcmp(v.Attribute(i).Name,'units') ),
    str=v.Attribute(i).Value;
    str=regexprep(str,'.* since ','');
    epoch=datenum(str,'yyyy-mm-dd HH:MM:SS');
  end
end

