function seawifscolorbar(colpos,vname,fsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2002
%
% function seawifscolorbar(colpos,vname,fsize)
%
% put a seawifs colorbar at a fixed position
%
% input:
%
%  colpos   position of the colorbar [left, bottom, width, height]
%  vname    name of the variable (string)
%           (default: 'temp')
%  fsize    font size  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot('position',colpos)
y=[0:1];
x=[0:256];
[Y,X]=meshgrid(y,x);
pcolor(X,Y,X)

L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50];
l=(log10(L)+2)/0.015;
set(gca,'YTick',y,'YTickLabel',[' '])
set(gca,'XTick',l,'XTickLabel',L)
shading flat
caxis([0 256])
load seawifs.dat
colormap(seawifs);
set(gca,'FontSize',fsize)
return
