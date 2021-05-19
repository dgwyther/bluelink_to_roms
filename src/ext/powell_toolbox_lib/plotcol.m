function handle = plotcol(x,y,z,c,linestyle);
% PLOTCOL generates a line plot that uses the color map.
% 
% PLOTCOL(X,Y,Z,C,LINESTYLE) plots a colored parametric
% line based on X, Y, Z, and C using the line style
% LINESTYLE. The color scaling is determined by the
% values of C or by the current setting of CAXIS. The
% scaled color values are used as indices into the 
% current COLORMAP.
%
% Any combination of inputs can be used. If C is not
% given, it is assigned to Z, Y, or X, depending on the
% input. Below is a table which describes this:
%
% GIVEN VALUE OF C
% X,Y,Z Z
% X,Y Y
% X X
%
% SEE ALSO: mesh

if nargin == 0;error('Requires at least one input');end

% Determine which inputs were given:
if nargin == 1; % 2-D plot, X given.
  % Make all inputs into row vectors
  x = x(:)';
  [m,n] = size(x);
  y = [x;x];
  x = [1:n;1:n];
  z = zeros(2,n);
  c = y;
  
elseif nargin == 2; % 2-D plot, X and Y, C, 
		    %or LINESTYLE are given
  x = x(:)';
  [m,n] = size(x);
  z = zeros(2,n);
  
  if isstr(y) % X and LINESTYLE given.
    y = [x;x];
    x = [1:n,1:n];
    
  else % X and Y given.
    y = y(:)';
    y = [y;y];
    
  end
  
  c = y;
  
elseif nargin == 3; % X, Y, and Z, or 
		    %LINESTYLE given.
  x = x(:)';
  y = y(:)';
  [m,n] = size(x);

  x = [x;x];
  y = [y;y];
  
  if ~isstr(z) % X, Y, and Z given
    z = z(:)';
    z = [z;z];
    c = z;
    
    
  else % X, Y, and LINESTYLE
       % given
    linestyle = z;
    z = zeros(2,n);
    c = y;
    
  end
  
elseif nargin == 4 % X, Y, and Z, C, or 
		   % LINESTYLE given.
  x = x(:)';
  y = y(:)';
  [m,n] = size(x);
  x = [x;x];
  y = [y;y];
  
  if isstr(c) % 2-D plot with X, Y, 
              % C, and LINESTYLE
    linestyle = c;
    c = z;
    z = zeros(2,n);
    
  else % 3-D plot with X, Y, 
       % Z, and C or LINESTYLE
    z = z(:)';
    c = c(:)';
    z = [z;z];
    c = [c;c];
    
  end
  
elseif nargin == 5 % Everything given.
  x = x(:)';
  y = y(:)';
  z = z(:)';
  c = c(:)';
  [m,n] = size(x);
  x = [x;x];
  y = [y;y];
  z = [z;z];
  c = [c;c];
  
end

h = mesh(x,y,z,c,'LineStyle','none','Marker','.');
if all(z == 0), view(2), end

if nargout == 1
  handle = h;
end

view(2);
