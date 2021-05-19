cd /home/z3097808/eac/bluelink

BLg=grid_read('../grid/EACouter_BL_grid.nc');
romsg=grid_read('../grid/EACouter_varres_grd_mergedBLbry.nc');

disp(num2str([romsg.theta_s romsg.theta_b]));

for years=1994:2016 
 for halfyr=1:2

 tic

% if years<2012
hisfile='/srv/scratch/z3097808/bluelink_new/20years/EAC_BlueLink_his_1994_2016.nc';
climfile=['/srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_clim_',num2str(years),'_',num2str(halfyr),'.nc'];
 
 if halfyr==1;period=[datenum([years,1,1]),datenum([years,6,30])];
  elseif halfyr==2&years<2016;period=[datenum([years,7,1]),datenum([years,12,31])];
  elseif halfyr==2&years==2016;period=[datenum([years,7,1]),datenum([years,9,30])];
  end
 zlev_to_roms_clim_BlueLink_EACgrid(hisfile,climfile, BLg, romsg, 1,period);

% elseif years==2012&halfyr==1
%hisfile=['/srv/scratch/z3097808/bluelink/EAC_BRAN_his_',num2str(years),'_toAug1.nc'];
%climfile=['/srv/scratch/z3097808/bluelink/EAC_BRAN_clim_',num2str(years),'_toJun30.nc'];
% period=[datenum([years,1,1]),datenum([years,6,30])];
% zlev_to_roms_clim_BlueLink_EACgrid(hisfile,climfile, BLg, romsg, 1,period);

% else
% % do nothing
% end

  ttot=toc;
        if exist('climfile')
        fdone=['Generated ',climfile,' ------ took ',num2str(ttot),' seconds'];
        if years==2011&halfyr==1; fid = fopen('MLrunlog_clim.txt','w');end
        fprintf(fid,'%s\n',fdone);
        end
 end % end half year loop
end % end years loop
fclose(fid);



%zfile=hisfile;outfile=climfile;zgrd=BLg;rgrd=romsg;averaging=1;





%hisfile='/srv/scratch/z3097808/bluelink/EAC_BRAN3p5_his_2002_1Aug2012.nc';
%climfile='/srv/scratch/z3097808/bluelink/EAC_BRAN3p5_clim_2002_1Aug2012.nc';

% zlev_to_roms_clim_BlueLink_EACgrid(hisfile,climfile, BLg, romsg, 7);
