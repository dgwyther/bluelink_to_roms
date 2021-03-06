function ncrst=create_nestedrestart(rstfile,gridfile,parentfile,title,clobber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%                                                                 %
%                                                                 %
%   This function create the header of a Netcdf climatology       %
%   file.                                                         %
%                                                                 %
%                                                                 %
%   Input:                                                        %
%                                                                 %
%   rstfile      Netcdf restart file name (character string).     %
%   gridfile     Netcdf grid file name (character string).        %
%   N            Number of vertical levels.(Integer)              %
%   time         restart time.(Real)                              %
%   clobber      Switch to allow or not writing over an existing  %
%                file.(character string)                          %
%                                                                 %
%                                                                 %
%   Output                                                        %
%                                                                 %
%   ncrst       Output netcdf object.                             %
%                                                                 %
% Pierrick Penven 2004                                            %
%                                                                 %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
biol=0;
disp(' ')
disp(' ')
disp(['Creating the file : ',rstfile])
disp(' ')
%
%  Open the grid file
%
ncgrd = netcdf(gridfile,'nowrite');
%
%  Open the parent file
%
ncprt=netcdf(parentfile,'nowrite');
%
%  Create the restart file
%
type = 'restart file' ; 
history = 'ROMS' ;
ncrst = netcdf(rstfile,clobber);
redef(ncrst);
%
%  Create dimensions
%
ncrst('xi_u') = length(ncgrd('xi_u'));
ncrst('xi_rho') = length(ncgrd('xi_rho'));
ncrst('eta_v') = length(ncgrd('eta_v'));
ncrst('eta_rho') = length(ncgrd('eta_rho'));
ncrst('s_rho') = length(ncprt('s_rho'));
ncrst('s_w') = length(ncprt('s_w'));
ncrst('one') = 1;
ncrst('auxil')  = 4 ;
ncrst('time') = 0;
ncrst('one') = 1;
%
%  Create variables
%
ncrst{'spherical'} = ncchar('one');
ncrst{'el'} = ncdouble('one');
ncrst{'xl'} = ncdouble('one');
ncrst{'h'} = ncdouble('eta_rho','xi_rho');
ncrst{'f'} = ncdouble('eta_rho','xi_rho');
ncrst{'pm'} = ncdouble('eta_rho','xi_rho');
ncrst{'pn'} = ncdouble('eta_rho','xi_rho');
ncrst{'lon_rho'} = ncdouble('eta_rho','xi_rho');
ncrst{'lat_rho'} = ncdouble('eta_rho','xi_rho');
ncrst{'angle'} = ncdouble('eta_rho','xi_rho');
ncrst{'mask_rho'} = ncdouble('eta_rho','xi_rho');
ncrst{'time_step'} = ncint('time','auxil');
ncrst{'scrum_time'} = ncdouble('time');
ncrst{'u'} = ncdouble('time','s_rho','eta_rho','xi_u');
ncrst{'v'} = ncdouble('time','s_rho','eta_v','xi_rho');
ncrst{'ubar'} = ncdouble('time','eta_rho','xi_u');
ncrst{'vbar'} = ncdouble('time','eta_v','xi_rho');
ncrst{'zeta'} = ncdouble('time','eta_rho','xi_rho');
ncrst{'temp'} = ncdouble('time','s_rho','eta_rho','xi_rho');
ncrst{'salt'} = ncdouble('time','s_rho','eta_rho','xi_rho');
if biol==1
  ncrst{'NO3'} = ncdouble('time','s_rho','eta_rho','xi_rho');
  ncrst{'NH4'} = ncdouble('time','s_rho','eta_rho','xi_rho');
  ncrst{'CHLA'} = ncdouble('time','s_rho','eta_rho','xi_rho');
  ncrst{'PHYTO'} = ncdouble('time','s_rho','eta_rho','xi_rho');
  ncrst{'ZOO'} = ncdouble('time','s_rho','eta_rho','xi_rho');
  ncrst{'SDET'} = ncdouble('time','s_rho','eta_rho','xi_rho');
  ncrst{'LDET'} = ncdouble('time','s_rho','eta_rho','xi_rho');
end
%
%  Create attributes
%
ncrst{'spherical'}.long_name = ncchar('grid type logical switch');
ncrst{'spherical'}.long_name = 'grid type logical switch';
%
ncrst{'xl'}.long_name = ncchar('domain length in the XI-direction');
ncrst{'xl'}.long_name = 'domain length in the XI-direction';
ncrst{'xl'}.units = ncchar('meter');
ncrst{'xl'}.units = 'meter';
%
ncrst{'el'}.long_name = ncchar('domain length in the ETA-direction');
ncrst{'el'}.long_name = 'domain length in the ETA-direction';
ncrst{'el'}.units = ncchar('meter');
ncrst{'el'}.units = 'meter';
%
ncrst{'h'}.long_name = ncchar('bathymetry at RHO-points');
ncrst{'h'}.long_name = 'bathymetry at RHO-points';
ncrst{'h'}.units = ncchar('meter');
ncrst{'h'}.units = 'meter';
%
ncrst{'f'}.long_name = ncchar('Coriolis parameter at RHO-points');
ncrst{'f'}.long_name = 'Coriolis parameter at RHO-points';
ncrst{'f'}.units = ncchar('second-1');
ncrst{'f'}.units = 'second-1';
%
ncrst{'pm'}.long_name = ncchar('curvilinear coordinate metric in XI');
ncrst{'pm'}.long_name = 'curvilinear coordinate metric in XI';
ncrst{'pm'}.units = ncchar('meter-1');
ncrst{'pm'}.units = 'meter-1';
%
ncrst{'pn'}.long_name = ncchar('curvilinear coordinate metric in ETA');
ncrst{'pn'}.long_name = 'curvilinear coordinate metric in ETA';
ncrst{'pn'}.units = ncchar('meter-1');
ncrst{'pn'}.units = 'meter-1';
%
ncrst{'lon_rho'}.long_name = ncchar('longitude of RHO-points');
ncrst{'lon_rho'}.long_name = 'longitude of RHO-points';
ncrst{'lon_rho'}.units = ncchar('degree_east');
ncrst{'lon_rho'}.units = 'degree_east';
%
ncrst{'lat_rho'}.long_name = ncchar('latitude of RHO-points');
ncrst{'lat_rho'}.long_name = 'latitude of RHO-points';
ncrst{'lat_rho'}.units = ncchar('degree_north');
ncrst{'lat_rho'}.units = 'degree_north';
%
ncrst{'angle'}.long_name = ncchar('angle between XI-axis and EAST');
ncrst{'angle'}.long_name = 'angle between XI-axis and EAST';
ncrst{'angle'}.units = ncchar('radians');
ncrst{'angle'}.units = 'radians';
%
ncrst{'mask_rho'}.long_name = ncchar('mask on RHO-points');
ncrst{'mask_rho'}.long_name = 'mask on RHO-points';
%
ncrst{'time_step'}.long_name = ncchar('time step and record numbers from initialization');
ncrst{'time_step'}.long_name = 'time step and record numbers from initialization';
%
ncrst{'scrum_time'}.long_name = ncchar('time since intialization');
ncrst{'scrum_time'}.long_name = 'time since intialization';
ncrst{'scrum_time'}.units = ncchar('second');
ncrst{'scrum_time'}.units = 'second';
%
ncrst{'u'}.long_name = ncchar('u-momentum component');
ncrst{'u'}.long_name = 'u-momentum component';
ncrst{'u'}.units = ncchar('meter second-1');
ncrst{'u'}.units = 'meter second-1';
%
ncrst{'v'}.long_name = ncchar('v-momentum component');
ncrst{'v'}.long_name = 'v-momentum component';
ncrst{'v'}.units = ncchar('meter second-1');
ncrst{'v'}.units = 'meter second-1';
%
ncrst{'ubar'}.long_name = ncchar('vertically integrated u-momentum component');
ncrst{'ubar'}.long_name = 'vertically integrated u-momentum component';
ncrst{'ubar'}.units = ncchar('meter second-1');
ncrst{'ubar'}.units = 'meter second-1';
%
ncrst{'vbar'}.long_name = ncchar('vertically integrated v-momentum component');
ncrst{'vbar'}.long_name = 'vertically integrated v-momentum component';
ncrst{'vbar'}.units = ncchar('meter second-1');
ncrst{'vbar'}.units = 'meter second-1';
%
ncrst{'zeta'}.long_name = ncchar('free-surface');
ncrst{'zeta'}.long_name = 'free-surface';
ncrst{'zeta'}.units = ncchar('meter');
ncrst{'zeta'}.units = 'meter';
%
ncrst{'temp'}.long_name = ncchar('potential temperature');
ncrst{'temp'}.long_name = 'potential temperature';
ncrst{'temp'}.units = ncchar('Celsius');
ncrst{'temp'}.units = 'Celsius';
%
ncrst{'salt'}.long_name = ncchar('salinity');
ncrst{'salt'}.long_name = 'salinity';
ncrst{'salt'}.units = ncchar('PSU');
ncrst{'salt'}.units = 'PSU';
%
if biol==1
%
  ncrst{'NO3'}.long_name = ncchar('NO3 Nutrient');
  ncrst{'NO3'}.long_name = 'NO3 Nutrient';
  ncrst{'NO3'}.units = ncchar('mMol N m-3');
  ncrst{'NO3'}.units = 'mMol N m-3';
%
  ncrst{'NH4'}.long_name = ncchar('NH4 Nutrient');
  ncrst{'NH4'}.long_name = 'NH4 Nutrient';
  ncrst{'NH4'}.units = ncchar('mMol N m-3');
  ncrst{'NH4'}.units = 'mMol N m-3';
%
  ncrst{'CHLA'}.long_name = ncchar('Chlorophyl A');
  ncrst{'CHLA'}.long_name = 'Chlorophyl A';
  ncrst{'CHLA'}.units = ncchar('mMol N m-3');
  ncrst{'CHLA'}.units = 'mMol N m-3';
%
  ncrst{'PHYTO'}.long_name = ncchar('Phytoplankton');
  ncrst{'PHYTO'}.long_name = 'Phytoplankton';
  ncrst{'PHYTO'}.units = ncchar('mMol N m-3');
  ncrst{'PHYTO'}.units = 'mMol N m-3';
%
  ncrst{'ZOO'}.long_name = ncchar('Zooplankton');
  ncrst{'ZOO'}.long_name = 'Zooplankton';
  ncrst{'ZOO'}.units = ncchar('mMol N m-3');
  ncrst{'ZOO'}.units = 'mMol N m-3';
%
  ncrst{'SDET'}.long_name = ncchar('Small Detritus Nutrient');
  ncrst{'SDET'}.long_name = 'Small Detritus Nutrient';
  ncrst{'SDET'}.units = ncchar('mMol N m-3');
  ncrst{'SDET'}.units = 'mMol N m-3';
%
  ncrst{'LDET'}.long_name = ncchar('Large Detritus Nutrient');
  ncrst{'LDET'}.long_name = 'Large Detritus Nutrient';
  ncrst{'LDET'}.units = ncchar('mMol N m-3');
  ncrst{'LDET'}.units = 'mMol N m-3';
%
end
%
% Create global attributes
%
ncrst.type = ncchar(type);
ncrst.type = type;
ncrst.title = ncchar(title);
ncrst.title = title;
ncrst.date = ncchar(date);
ncrst.date = date;
ncrst.rst_file = ncchar(rstfile);
ncrst.rst_file = rstfile;
ncrst.grd_file = ncchar(gridfile);
ncrst.grd_file = gridfile;
ncrst.parent_file = ncchar(parentfile);
ncrst.parent_file = parentfile;
ncrst.history = ncchar(history);
ncrst.history = history;
%
% Get the vertical grid
%
ncrst.theta_s=ncprt.theta_s(:);
ncrst.theta_b=ncprt.theta_b(:);
ncrst.hc=ncprt.hc(:);
ncrst.sc_w=ncprt.sc_w(:);
ncrst.Cs_w=ncprt.Cs_w(:);
ncrst.sc_r=ncprt.sc_r(:);
ncrst.Cs_r=ncprt.Cs_r(:);
ncrst.ntimes=ncprt.ntimes(:);
ncrst.ndtfast=ncprt.ndtfast(:);
ncrst.dt=ncprt.dt(:);
ncrst.dtfast=ncprt.dtfast(:);
ncrst.nwrt=ncprt.nwrt(:);
ncrst.visc2=ncprt.visc2(:);
ncrst.rdrg=ncprt.rdrg(:);
ncrst.rdrg2=ncprt.rdrg2(:);
ncrst.rho0=ncprt.rho0(:);
ncrst.gamma2=ncprt.gamma2(:);
ncrst.SRCS=ncprt.SRCS(:);
ncrst.CPPS=ncprt.CPPS(:);
%
% Leave define mode
%
endef(ncrst);
%
% Fill variables
%
ncrst{'spherical'}(:)=ncgrd{'spherical'}(:);
ncrst{'el'}(:)=ncgrd{'el'}(:);
ncrst{'xl'}(:)=ncgrd{'xl'}(:);
ncrst{'h'}(:)=ncgrd{'h'}(:);
ncrst{'f'}(:)=ncgrd{'f'}(:);
ncrst{'pm'}(:)=ncgrd{'pm'}(:);
ncrst{'pn'}(:)=ncgrd{'pn'}(:);
ncrst{'lon_rho'}(:)=ncgrd{'lon_rho'}(:);
ncrst{'lat_rho'}(:)=ncgrd{'lat_rho'}(:);
ncrst{'angle'}(:)=ncgrd{'angle'}(:);
ncrst{'mask_rho'}(:)=ncgrd{'mask_rho'}(:);
%
% Synchronize on disk
%
sync(ncrst);
close(ncgrd);
close(ncprt);
return


