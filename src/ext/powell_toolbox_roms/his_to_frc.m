function nc = his_to_frc( file )

% nc = his_to_frc( file )
%
% Give a history file with the fluxes and wind stresses, create
% a forcing file.

if (nargin<1 | ~exist(file,'file'))
  error('you must specify a valid file')
end

time=nc_varget(file,'ocean_time');
v=nc_getvarinfo(file,'ocean_time');
epoch_str=v.Attribute(find(strcmp({v.Attribute.Name},'units'))).Value;
nc.roms_grid=true;

% 1) SST
sst=nc_varget(file,'temp');
sst=squeeze(sst(:,end,:,:));
nc.var(1).roms_variable_name = 'SST';
nc.var(1).long_name = 'sea surface temperature';
nc.var(1).units='Celcius';
nc.var(1).field='rho';
nc.var(1).time_str = 'sst_time';
nc.var(1).epoch_str=epoch_str;
nc.var(1).data=sst;
nc.var(1).data_time=time;

% 2) SHFLUX
data=nc_varget(file,'shflux');
nc.var(2).roms_variable_name = 'shflux';
nc.var(2).long_name = 'surface net heat flux';
nc.var(2).units='Watts meter-2';
nc.var(2).field='rho';
nc.var(2).time_str = 'shf_time';
nc.var(2).epoch_str=epoch_str;
nc.var(2).data=data;
nc.var(2).data_time=time;

% 3) SSS
salt=nc_varget(file,'salt');
salt=squeeze(salt(:,end,:,:));
nc.var(3).roms_variable_name = 'SSS';
nc.var(3).long_name = 'sea surface salinity';
nc.var(3).units='PSU';
nc.var(3).field='rho';
nc.var(3).time_str = 'sss_time';
nc.var(3).epoch_str=epoch_str;
nc.var(3).data=salt;
nc.var(3).data_time=time;

% 4) SWFLUX
data=nc_varget(file,'ssflux');
l=find(salt~=0);
data(l)=data(l)./salt(l);
nc.var(4).roms_variable_name = 'swflux';
nc.var(4).long_name = 'surface freshwater flux (E-P)';
nc.var(4).units='centimeter day-1';
nc.var(4).field='rho';
nc.var(4).time_str = 'swf_time';
nc.var(4).epoch_str=epoch_str;
nc.var(4).data=data;
nc.var(4).data_time=time;

% 5) SWRAD
data=nc_varget(file,'swrad');
nc.var(5).roms_variable_name = 'swrad';
nc.var(5).long_name = 'solar shortwave radiation';
nc.var(5).units='Watts meter-2';
nc.var(5).field='rho';
nc.var(5).time_str = 'srf_time';
nc.var(5).epoch_str=epoch_str;
nc.var(5).data=data;
nc.var(5).data_time=time;

% 6) DQDSST
data=nc_varget(file,'shflux');
l=find(sst~=0);
data(l)=data(l)./sst(l);
nc.var(6).roms_variable_name = 'dQdSST';
nc.var(6).long_name = 'surface net heat flux sensitivity to SST';
nc.var(6).units='Watts meter-2 Celsius-1';
nc.var(6).field='rho';
nc.var(6).time_str = 'sst_time';
nc.var(6).epoch_str=epoch_str;
nc.var(6).data=data;
nc.var(6).data_time=time;

% 7/8) SU/VSTR
data=nc_varget(file,'sustr');
nc.var(7).roms_variable_name = 'sustr';
nc.var(7).long_name = 'surface u-momentum stress';
nc.var(7).units='Newton meter-2';
nc.var(7).field='rho';
nc.var(7).time_str = 'sms_time';
nc.var(7).epoch_str=epoch_str;
nc.var(7).roms_u=true;
nc.var(7).data=data;
nc.var(7).data_time=time;
data=nc_varget(file,'svstr');
nc.var(8).roms_variable_name = 'svstr';
nc.var(8).long_name = 'surface v-momentum stress';
nc.var(8).units='Newton meter-2';
nc.var(8).field='rho';
nc.var(8).time_str = 'sms_time';
nc.var(8).epoch_str=epoch_str;
nc.var(8).roms_v=true;
nc.var(8).data=data;
nc.var(8).data_time=time;


% Done
nc.vars=length(nc.var);