clear all; close all;
%system('./load_netcdf_module.sh');

addpath(genpath('../ext/'))
addpath(genpath('../../conf/'))

opt = set_default_options()

BLg=grid_read(opt.grid_path_bluelink);
romsg=grid_read(opt.grid_path_roms);

%disp(num2str([romsg.theta_s romsg.theta_b]));
disp(['starting making climfiles at ',datestr(now)])

for years=opt.years(1):opt.years(end) 
 for halfyr=1:2

 tic

hisfile=opt.outfile;
climfile=[opt.climfile_path,opt.climfile_prefix,num2str(years),'_',num2str(halfyr),'.nc'];
 
 if halfyr==1;
	 period=[datenum([years,1,1]),datenum([years,6,30])];
 elseif halfyr==2;
	 period=[datenum([years,7,1]),datenum([years,12,31])];
 end
 zlev_to_roms_clim_BlueLink_EACgrid(hisfile,climfile, BLg, romsg, 1,period);

  ttot=toc;
        if exist('climfile')
        fdone=['Generated ',climfile,' ------ took ',num2str(ttot),' seconds'];
        if years==opt.years(1)&halfyr==1; fid = fopen('MLrunlog_clim.log','w');end
        fprintf(fid,'%s\n',fdone);
	disp(fdone)
        end
 end % end half year loop
end % end years loop
fclose(fid);
disp(['done at ',datestr(now)])
