function [h_shade,h_line] = errorshade(x, y, l, u, varargin)

% ERRORSHADE   PLOT SHADED ERRORBARS RATHER THAN LINES
%
% Similar to the errorbar routine, this plots a shaded
% region covering the upper and lower spans of the error.
% 
% SYNTAX
%   [h_shade, h_line] = ERRORSHADE(X, Y, L, U, OPTIONS)
% 
%
% Created by Brian Powell on 2008-04-09.
% Copyright (c)  powellb. All rights reserved.
%


if ( nargin < 3)
  error('you must specify an error');
end
if ( nargin < 4 )
  u=l;
elseif ( ischar(u))
  varargin={u, varargin{:}};
  u=l;
end

fillcolor = [0.9 0.9 0.9];

% First, construct the fill
% check sizes
x=x(:);
y=y(:);
l=l(:);
u=u(:);
if ( isscalar(l) )
  l=ones(size(y))*l;
end
if ( isscalar(u) )
  u=ones(size(y))*u;
end

fill_x = [x; x(end:-1:1)];
fill_y = [y-l; y(end:-1:1)+u(end:-1:1)];
h_shade = fill(fill_x,fill_y,fillcolor);
set(h_shade,'EdgeAlpha',0);
set(h_shade,'EdgeColor',fillcolor);

% Plot the main line
hold on;
h_line = plot(x,y,varargin{:});
