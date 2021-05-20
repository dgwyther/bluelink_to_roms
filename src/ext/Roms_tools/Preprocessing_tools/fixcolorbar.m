function fixcolorbar(colpos,colaxis,vname,fsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
% function fixcolorbar(colpos,colaxis,vname,fsize)
%
% put a colorbar at a fixed position
%
% input:
%
%  colpos   position of the colorbar [left, bottom, width, height]
%  colaxis  = [cmin cmax]: values assigned to the first and 
%           last colors in the current colormap 
%           (default: fit the min and max values of the variable)  
%  vname    name of the variable (string)
%           (default: 'temp')
%  fsize    font size  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dc=(colaxis(2)-colaxis(1))/64;
subplot('position',colpos)
x=[0:1];
y=[colaxis(1):dc:colaxis(2)];
[X,Y]=meshgrid(x,y);
pcolor(Y,X,Y)
shading flat
%contourf(Y,X,Y,[colaxis(1):dc:colaxis(2)])

set(gca,'YTick',y,'YTickLabel',[' '])
%set(gca,'Ydir','normal')
%set(gca,'TickDir','out')
%set(gca,'YGrid','on')
%set(gca,'YTick',y,'YTickLabel',y)
%set(gca,'YAxisLocation','right')
set(gca,'FontSize',fsize)
%title(vname,'FontSize',fsize)
%xlabel(vname,'FontSize',fsize)
return
