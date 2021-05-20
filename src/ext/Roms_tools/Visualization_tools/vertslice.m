function vertslice(hisfile,gridfile,lonsec,latsec,vname,tindex,...
                   coef,colmin,colmax,ncol,zmin,zmax,xmin,xmax,...
		   pltstyle,h0,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Pierrick 2002
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Defaults values
%
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gridfile=hisfile;
  disp('Default grid name: ',gridfile)
end
if nargin < 3
  lonsec=[];
end
if nargin < 4
  latsec=[];
end
if nargin < 5
  vname='temp';
  disp('Default variable to plot: ',vname)
end
if nargin < 6
  tindex=1;
  disp('Default time index: ',num2str(tindex))
end
if nargin < 7
  coef=1;
end
if nargin < 8
  colmin=[];
end
if nargin < 9
  colmax=[];
end
if nargin < 10
  ncol=10;
end
if nargin < 11
  zmin=[];
end
if nargin < 12
  zmax=[];
end
if nargin < 13
  xmin=[];
end
if nargin < 14
  xmax=[];
end
if nargin < 15
  pltstyle=1;
end
%
% Define figure location
%
if ~isempty(h0)
  set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes1);
  cla
end
%
% Get default values
%
if isempty(gridfile)
  gridfile=hisfile;
end
if isempty(lonsec) | isempty(latsec)
  [lat,lon,mask]=read_latlonmask(gridfile,'r');
  latsec=mean(mean(lat));
  lonsec=[min(min(lon)) max(max(lon))];
end
%
% Get the section
%
if vname(1)=='*'
  if vname(2:4)=='Ke '
    [x,z,u]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'u',tindex);
    [x,z,v]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'v',tindex);
    var=coef.*0.5.*(u.^2+v.^2);
  elseif vname(2:4)=='Spd'
    [x,z,u]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'u',tindex);
    [x,z,v]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'v',tindex);
    var=coef.*sqrt(u.^2+v.^2);
  elseif vname(2:4)=='Rho'
    [x,z,temp]=get_section(hisfile,gridfile,lonsec,latsec,...
                           'temp',tindex);
    [x,z,salt]=get_section(hisfile,gridfile,lonsec,latsec,...
                          'salt',tindex);
    var=coef*rho_eos(temp,salt,z);
  elseif vname(2:4)=='Rpo'
    [x,z,temp]=get_section(hisfile,gridfile,lonsec,latsec,...
                           'temp',tindex);
    [x,z,salt]=get_section(hisfile,gridfile,lonsec,latsec,...
                          'salt',tindex);
    var=coef*rho_pot(temp,salt);
  elseif vname(2:4)=='Bvf'
    disp('Sorry not implemented yet')
    return
  else
    disp('Sorry not implemented yet')
    return
  end 
else
  [x,z,var]=get_section(hisfile,gridfile,lonsec,latsec,...
                        vname,tindex);
end
%
% Colors
%
maxvar=max(max(var));
minvar=min(min(var));
if isempty(colmin)
  colmin=minvar;
end
if isempty(colmax)
  colmax=maxvar;
end
%
% Domain size
%
if isempty(xmin)
  xmin=min(min(x));
end
if isempty(xmax)
  xmax=max(max(x));
end
if isempty(zmin)
  zmin=min(min(z));
end
if isempty(zmax)
  zmax=max(max(z));
end
%
% Get the date
%
[day,month,year,thedate]=...
get_date(hisfile,tindex);
%
% Do the contours
%
if maxvar>minvar
  if pltstyle==1
    pcolor(x,z,var);
    ncol=128;
    shading interp
  elseif pltstyle==2
    contourf(x,z,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax]);
%    shading flat
  elseif pltstyle==3
    [C,h1]=contour(x,z,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax],'k');
     clabel(C,h1,'LabelSpacing',1000,'Rotation',0)
  elseif pltstyle==4
   dcol=(colmax-colmin)/ncol;
   if minvar <0 
     [C11,h11]=contourf(x,z,var,[minvar 0]);
      caxis([minvar 0]);
   end
   if colmin < 0
     if minvar < 0 
       hold on
     end
     val=[colmin:dcol:min([colmax -dcol])];
     if length(val)<2
       val=[colmin colmin];
     end  
     [C12,h12]=contour(x,z,var,val,'k');
     if ~isempty(h12)
       clabel(C12,h12,'LabelSpacing',1000,'Rotation',0)
       set(h12,'LineStyle',':')
     end
     hold off
   end
   if colmax > 0
     if colmin < 0 | minvar < 0
       hold on
     end
     val=[max([dcol colmin]):dcol:colmax];
     if length(val)<2
       val=[colmax colmax];
     end  
     [C13,h13]=contour(x,z,var,val,'k');
     if ~isempty(h13)
       clabel(C13,h13,'LabelSpacing',1000,'Rotation',0)
     end
     hold off 
   end
   hold on
   [C10,h10]=contour(x,z,var,[0 0],'k');
   if ~isempty(h10)
     clabel(C10,h10,'LabelSpacing',1000,'Rotation',0)
     set(h10,'LineWidth',1.2)
   end
   hold off
   map=0.9+zeros(64,3);
   map2=1+zeros(32,3);
   map(33:64,:)=map2;
   colormap(map)
  end
  if pltstyle<=2
    caxis([colmin colmax])
    colormap(jet)
    colorbar
  end
  axis([xmin xmax zmin zmax])
end
xlabel('Position along the section [km]')
ylabel('Depth [m]')
title([vname,' - ',thedate])
return

