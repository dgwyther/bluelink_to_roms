function add_arrow(lonmin,lonmax,latmin,latmax,cunit,cscale,width,height)
%
% add an arrow in a vector plot (under m_map)
%

[x(1),y(1)]=m_ll2xy(lonmin,latmin); %coin bas gauche
[x(2),y(2)]=m_ll2xy(lonmax,latmin); %coin bas droite
[x(3),y(3)]=m_ll2xy(lonmin,latmax); %coin haut gauche
[x(4),y(4)]=m_ll2xy(lonmax,latmax); %coin haut droite
xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
fac=0.01;
long=lonmin+fac*(lonmax-lonmin);
lat=latmax-fac*(latmax-latmin);
U=cunit*cscale;
V=0;
[X,Y]=m_ll2xy(long,lat,'clip','point');
[XN,YN]=m_ll2xy(long,lat+.01,'clip','point');
[XE,YE]=m_ll2xy(long+(.01)./cos(lat*pi/180),lat,'clip','point');
mU=U.*(XE-X)*100 + V.*(XN-X)*100;
mV=U.*(YE-Y)*100 + V.*(YN-Y)*100;
larrow=sqrt(mU.^2+mV.^2);
ratio1=(xmax-xmin)/(ymax-ymin);
ratio2=width/height;
if ratio2>=ratio1
 width=ratio1*width/ratio2;
else
 height=ratio2*width/ratio1;
end 
subplot('position',[0.6 0.06-height width height])
quiver(X,Y,larrow,0,0,'k')
text(X+larrow/2,Y,[num2str(cunit),' m.s^{-1}'],...
'HorizontalAlignment','center',...
'VerticalAlignment','bottom')
axis image                 
axis([xmin xmax ymin ymax])
set(gca,'visible','off')
