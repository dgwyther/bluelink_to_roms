function olap = overlap(x,y)
%   OVERLAP   RETURNS BOOLEAN IF TWO VECTORS OVERLAP
%     [OLAP] = OVERLAP(X,Y)
% 
% Given two vectors of data, do they overlap in any part of 
% their space? This is distinct from matlab's union & intersect.

olap=false;

mnx=min(x);
mxx=max(x);
mny=min(y);
mxy=max(y);

mnd=mnx-mny;
mxd=mxx-mxy;

if ( mnd > 0 & mxy > mnx ) || ...
   ( mnd < 0 & -mnd < (mxx-mnx) )
     olap=true;
end

end %  function
