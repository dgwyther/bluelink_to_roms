function make_bry_std(opt,bry,his,out)
%   MAKE_BRY_STD   Generate 4D-Var Boundary Standard Deviations File
%     MAKE_BRY_STD(OPT,BRY,HIS,OUT,NRECS)
% 
%   Given options, boundary record, sample history file, and the
%   output file, create a 4D-Var boundary conditions standard
%   deviation file
%   
%   Created by Brian Powell on 2009-09-29.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.

nrecs=opt.nrecs;
g=grid_read(opt.grid);

% Create the appropriately sized boundary std file -- much faster using ncgen
disp(['create boundary std file: ' out]);
unix([regexprep(which('bry_std_write'),'\.m$','\.sh') ' ' out ' ' ...
      num2str([g.lp g.mp g.n])]);

% Copy the following variables from the history file into the boundary
vars={'spherical' 'theta_s' 'theta_b' 'Tcline' 'hc' 's_rho' 's_w' 'Cs_r'  ...
      'Cs_w' 'h' 'lon_rho' 'lat_rho' 'lon_u' 'lat_u' 'lon_v' 'lat_v'  ...
      'angle' 'mask_rho' 'mask_u' 'mask_v' 'Vtransform' 'Vstretching'};

for v=1:length(vars),
  vr=char(vars(v));
  nc_varput(out,vr,nc_varget(his,vr));
end

% Get the boundary times
bt = nc_varget(bry,'bry_time');
[ssn,mon]=season(bt+opt.epoch);

% Next, go through the boundary standard deviations file and convert to
% the 4D-Var file
vars={'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt'};
dirs={'west' 'south' 'east' 'north'};
dims=[2 2 2 3 3 3 3];

tot=nrecs*length(vars)*length(dirs);
progress(0,0,1);
count=0;
for t=1:nrecs,
  if nrecs==12,
    l=find(mon==t);
  elseif nrecs==4,
    l=find(ssn==t);
  else
    l=[1:length(mon)];
  end
  rec=[];
  rec.ocean_time=(t-1)*floor(365/nrecs)+floor(365/nrecs/2);
  for v=1:length(vars),
    vr=char(vars(v));
    if (dims(v)==2)
      data=zeros(1,4,max(g.lp,g.mp));
    else
      data=zeros(1,4,g.n,max(g.lp,g.mp));
    end
    for d=1:length(dirs),
      count=count+1;
      progress(tot,count,1);
      dr=[vr '_' char(dirs(d))];
      dt=nc_varget(bry,dr);
      dt=squeeze(nanstd(dt(l,:)));
      data(1,d,1:numel(dt))=dt;
    end
    evalc(['rec.' vr '_obc=data']);
  end
  nc_addnewrecs(out, rec, 'ocean_time');
end
