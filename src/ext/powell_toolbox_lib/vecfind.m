function [l, m] = vecfind(a, b, tol, options)

% function [l,m] = vecfind(a, b, [tol])
% Given two vectors, a and b, find all instances of b that exist
% in a and return a list (l) of indices into a
% and a list (m) of indices into b
% if tol is specified, it will find within the tolerance

if ( nargin < 2 )
  error('You must specify two vectors');
end
if ( nargin < 4 )
  options='';
end
nearest=false;
if strcmp(options,'nearest')
  nearest=true;
end
a=reshape(a,1,length(a));
b=reshape(b,1,length(b));
l=[];
m=[];
if ( ~ length(b) | ~ length(a) )
  return;
end
if exist('tol')
  for i=1:length(b),
    d = abs(a-b(i));
    r = find(d < tol);
    if ( ~isempty(r) )
      if nearest
        r=r(find(d(r)==min(d(r))));
      end
      l = [ l r ];
      m = [ m i ];
    end
  end
else
  for i=1:length(b),
    r = min(find(a==b(i)));
    if ( ~isempty(r) )
      l = [ l r ];
      m = [ m i ];
    end
  end
end
% l = unique(l);
% m = unique(m);
