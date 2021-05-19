function [x,y] = calc_line(x,y)
%   CALC_LINE   Given endpoints, calculate a pixel line between the two
%     [x,y] = CALC_LINE(x,y)
% 
%   x = [x0 x1] and y=[y0 y1]. Output are x and y points
%   


x0=x(1);
x1=x(2);
y0=y(1);
y1=y(2);
steep = abs(y1 - y0) > abs(x1 - x0);
if steep,
  [x0,y0]=swap(x0,y0);
  [x1,y1]=swap(x1,y1);
end
if x0 > x1,
  [x0,x1]=swap(x0,x1);
  [y0,y1]=swap(y0,y1);
end
dx = x1 - x0;
dy = abs(y1 - y0);
err = dx / 2;
y(1) = y0;
ystep=sign(y1-y0);
x = [x0:x1]';
for i=2:length(x),
  err = err - dy;
  if err<0,
    y(i) = y(i-1) + ystep;
    err=err+dx;
  else
    y(i) = y(i-1);
  end
end
if steep,
  [x,y]=swap(x,y);
end
  function [a,b]=swap(a,b)
    c=a; a=b; b=c;
  end
end



 % function line(x0, x1, y0, y1)
 %     boolean steep := abs(y1 - y0) > abs(x1 - x0)
 %     if steep then
 %         swap(x0, y0)
 %         swap(x1, y1)
 %     if x0 > x1 then
 %         swap(x0, x1)
 %         swap(y0, y1)
 %     int deltax := x1 - x0
 %     int deltay := abs(y1 - y0)
 %     int error := deltax / 2
 %     int ystep
 %     int y := y0
 %     if y0 < y1 then ystep := 1 else ystep := -1
 %     for x from x0 to x1
 %         if steep then plot(y,x) else plot(x,y)
 %         error := error - deltay
 %         if error < 0 then
 %             y := y + ystep
 %             error := error + deltax
