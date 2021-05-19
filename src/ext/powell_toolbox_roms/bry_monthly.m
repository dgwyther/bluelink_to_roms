function bry_monthly( bryfile, climfile, epoch )

% bry_monthly( bryfile, climfile )
%
% Given a boundary file, create a monthly climatology. 
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<2)
  error('you must specify a filename');
end
if (nargin<3)
  epoch=datenum(1900,1,1);
end

if ( ~exist(bryfile,'file') | ~exist(climfile,'file') )
  error('file must exist');
end

dirs={'north' 'south' 'east' 'west'};
vars={'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt'};

times=nc_varget(bryfile,'bry_time') + epoch;
[ym,mm]=datevec(times);
for m=1:12,
  rec=[];
  rec.bry_time=15+(m-1)*30;
  l=find(mm==m);
  for d=1:length(dirs),
    for v=1:length(vars),
      var=[char(vars(v)) '_' char(dirs(d))];
      data = nc_varget(bryfile,var);
      s=size(data);
      s(1)=1;
      eval(sprintf('rec.%s=zeros(s);',var));
      if ( ~isempty(l) )
        eval(sprintf('rec.%s(1,:)=mean(data(l,:));',var));
      end
    end
  end
  nc_addnewrecs( climfile, rec, 'bry_time' );
end
