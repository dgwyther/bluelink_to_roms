function obs_to_his( obs_file, his_file, day )

% OBS_TO_HIS   Copy observation file data into a history file
%
% Given a ROMS observation file and a history file, extract the observations
% onto a history file structure.
% 
% SYNTAX
%   OBS_TO_HIS( OBS_FILE, HIS_FILE, DAY )
% 

if ( nargin < 2 )
  error('you must specify both an observations file and a history file');
end
if ( nargin < 3 )
  day=0;
end
o=obs_read(obs_file);

% Load and clear out the data
zetas = size(nc_varget(his_file,'zeta'));
zetas = zetas(2:3);
us    = size(nc_varget(his_file,'u'));
us    = us(2:4);
vs    = size(nc_varget(his_file,'v'));
vs    = vs(2:4);
temps = size(nc_varget(his_file,'temp'));
temps = temps(2:4);
salts = size(nc_varget(his_file,'salt'));
salts = salts(2:4);

vars = { 'zeta' 'u' 'v' 'temp' 'salt' };
type = [ 1 4 5 6 7 ];

if ( day )
  o.survey_time = day;
end

% Go over each survey, create the data and append it to the history file
for t=o.survey_time',
  clear rec
  rec.ocean_time=t*86400;

  % Do Zeta separately since it is a single layer
  rec.zeta=zeros(zetas);
  list = find( o.type == type(1) & o.time == t);
  if ( ~isempty(list) )
    disp(['found ' char(vars(1)) ' for ' num2str(t)]);
    rec.zeta(sub2ind(size(rec.zeta),round(o.y(list))+1,round(o.x(list))+1)) = ...
      o.value(list);
  end
  rec.zeta = reshape(rec.zeta,[1 zetas]);

  % Everything else
  for v=2:length(vars),
    eval(sprintf('s=%ss;',char(vars(v))));
    data=zeros(s);
    list = find( o.type == type(v) & o.time == t);
    if ( ~isempty(list) )
      disp(['found ' char(vars(v)) ' for ' num2str(t)]);
      data(sub2ind(size(data),round(o.depth(list)),round(o.y(list))+1,round(o.x(list))+1)) = ...
        o.value(list);
    end
    data=reshape(data,[1 s]);
    eval(sprintf('rec.%s=data;',char(vars(v))));
  end
  
  % Append this record to the history file
  nc_addnewrecs(his_file, rec, 'ocean_time');
end

