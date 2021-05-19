addpath(genpath('../ext/'))
addpath(genpath('../../conf/'))

set_default_options()


grid=grid_read(opt.grid_path_roms);



for years=opt.years(1):opt.years(end)
 for halfyr=1:2
 tic
 climfile=[opt.climfile_path,opt.climfile_prefix,num2str(years),'_',num2str(halfyr),'.nc'];
 bryfile=[opt.bryfile_path,opt.bryfile_prefix,num2str(years),'_',num2str(halfyr),'.nc'];

 bry_clim(grid, climfile, bryfile, opt.epoch_roms);
 ttot=toc;
        fdone=['Generated ',bryfile,' ------ took ',num2str(ttot),' seconds'];
        if years==1994&halfyr==1; fid = fopen('MLrunlog_bry.log','w');end
        fprintf(fid,'%s\n',fdone);
  end
end
fclose(fid);


