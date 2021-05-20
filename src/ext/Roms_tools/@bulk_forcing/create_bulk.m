function  create_forcing(frcname,grdname,title,bulkt,bulkc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf heat flux bulk forcing file
%       frcname: name of the forcing file
%       grdname: name of the grid file
%       title: title in the netcdf file  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(grdname);
L=length(nc('xi_psi'));
M=length(nc('eta_psi'));
result=close(nc);
Lp=L+1;
Mp=M+1;

nw = netcdf(frcname, 'clobber');
result = redef(nw);

%
%  Create dimensions
%
nw('xi_rho') = Lp;
nw('eta_rho') = Mp;
nw('xi_psi') = L;
nw('eta_psi') = M;
nw('bulk_time') = length(bulkt);
%
%  Create variables and attributes
%
nw{'bulk_time'} = ncdouble('bulk_time');
nw{'bulk_time'}.long_name = ncchar('bulk formulation execution time');
nw{'bulk_time'}.long_name = 'bulk formulation execution time';
nw{'bulk_time'}.units = ncchar('days');
nw{'bulk_time'}.units = 'days';
nw{'bulk_time'}.cycle_length = bulkc;

nw{'tair'} = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'tair'}.long_name = ncchar('surface air temperature 2m');
nw{'tair'}.long_name = 'surface air temperature 2m';
nw{'tair'}.units = ncchar('Celsius');
nw{'tair'}.units = 'Celsius';

nw{'rhum'} = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'rhum'}.long_name = ncchar('surface air relative humidity 2m');
nw{'rhum'}.long_name = 'surface air relative humidity 2m';
nw{'rhum'}.units = ncchar('fraction');
nw{'rhum'}.units = 'fraction';

nw{'prate'} = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'prate'}.long_name = ncchar('surface precipitation rate');
nw{'prate'}.long_name = 'surface precipitation rate';
nw{'prate'}.units = ncchar('cm day-1');
nw{'prate'}.units = 'cm day-1';

nw{'wspd'} = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'wspd'}.long_name = ncchar('wind speed 10m');
nw{'wspd'}.long_name = 'wind speed 10m';
nw{'wspd'}.units = ncchar('m s-1');
nw{'wspd'}.units = 'm s-1';

nw{'radlw'} = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'radlw'}.long_name = ncchar('net terrestrial longwave radiation');
nw{'radlw'}.long_name = 'net terrestrial longwave radiation';
nw{'radlw'}.units = ncchar('Watts meter-2');
nw{'radlw'}.units = 'Watts meter-2';
nw{'radlw'}.positive = ncchar('upward flux, cooling water');
nw{'radlw'}.positive = 'upward flux, cooling water';
nw{'radlw'}.negative = ncchar('downward flux, heating water');
nw{'radlw'}.negative = 'downward flux, heating water';

nw{'radsw'} = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'radsw'}.long_name = ncchar('net solar shortwave radiation');
nw{'radsw'}.long_name = 'net solar shortwave radiation';
nw{'radsw'}.units = ncchar('Watts meter-2');
nw{'radsw'}.units = 'Watts meter-2';
nw{'radsw'}.negative = ncchar('upward flux, cooling water');
nw{'radsw'}.negative = 'upward flux, cooling water';
nw{'radsw'}.positive = ncchar('downward flux, heating water');
nw{'radsw'}.positive = 'downward flux, heating water';

result = endef(nw);

%
% Create global attributes
%

nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.grd_file = ncchar(grdname);
nw.grd_file = grdname;
nw.type = ncchar('ROMS heat flux bulk forcing file');
nw.type = 'ROMS heat flux bulk forcing file';

%
% Write time variables
%

nw{'bulk_time'}(:) = bulkt;

close(nw);
