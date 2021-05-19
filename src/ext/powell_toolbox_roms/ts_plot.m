function h = ts_plot(t,s,varargin)

if nargin > 2
  fmt=varargin{1};
else
  fmt='b+';
end

% Given temp and salt, create a T/S plot
lims=[min(s)-.1 max(s)+.1 min(t)-.1 max(t)+.1];
[sal,tem]=meshgrid(linspace(lims(1),lims(2),50),linspace(lims(3),lims(4),50));
isopycnal=reshape(sw_dens0(sal(:),tem(:)),50,50);
[c,h]=contour(sal,tem,isopycnal-1000,'k','Color',[0.7 0.7 0.7]);
clabel(c,h);
hold on
h=plot(s,t,fmt);
xlabel('Salt');
ylabel('Temp (C)');
hold off
