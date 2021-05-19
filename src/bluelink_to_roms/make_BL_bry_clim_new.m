cd /home/z3097808/eac/bluelink

grid=grid_read('../grid/EACouter_varres_grd_mergedBLbry.nc');



for years=1994:2016;%2002:2012
 for halfyr=1:2
 tic
climfile=['/srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_clim_',num2str(years),'_',num2str(halfyr),'.nc'];
bryfile=['/srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_bry_',num2str(years),'_',num2str(halfyr),'.nc'];

bry_clim(grid, climfile, bryfile, datenum(2000,1,1));
 ttot=toc;
        fdone=['Generated ',bryfile,' ------ took ',num2str(ttot),' seconds'];
        if years==1994&halfyr==1; fid = fopen('MLrunlog_bry.txt','w');end
        fprintf(fid,'%s\n',fdone);
  end
end
fclose(fid);


