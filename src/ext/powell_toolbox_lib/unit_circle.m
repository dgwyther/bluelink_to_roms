function [x, y] = unit_circle(n)

% function [x, y] = unit_circle(n)
%
% This function will return meshgrid arrays of points that lie within a
% unit circle (-1,1) with the given number of n X n points.

x=linspace(-1,1,n);
[x,y]=meshgrid(x);
r = x.^2 + y.^2;
l = find(r>1);
x(l) = nan;
y(l) = nan;
