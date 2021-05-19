function rec = remove_land( grid, rec, dx )

% function rec = remove_land( grid, rec, dx )
% 
% This will take the record land_mask (from the data source), and blend
% the ocean points over the land boundaries. This will allow us to use the
% ROMS interpolation because it will not be contaminated by land points.
if (nargin < 3)
  dx=5;
end

% Use the data land mask that is now in grid coordinates
% and find the boundaries
step=100;
for v=1:length(rec.var),
  progress(0,0,1);
  % We have to be careful about the size of the data
  for i=1:step+1:size(rec.var(v).data,1),
    progress(size(rec.var(v).data,1),i);
    range=[i:min(i+step,size(rec.var(v).data,1))];
    kernel = zeros(dx,dx,length(range));
    kernel(:,:,1)=1;
    kernel(round((dx+1)/2),round((dx+1)/2),1)=0;
    mask = rec.land_mask(:,:,ones(length(range),1));
    [l,m,n] = size(mask);
    num=convn( mask,kernel );
    num=permute(num( 2:l+1,2:m+1,1:n ),[3 1 2]);
    con=convn( permute(rec.var(v).data(range,:,:),[2 3 1]) .* mask, kernel );
    con=permute(con( 2:l+1,2:m+1,1:n ),[3 1 2]);
    list = find( permute(mask,[3 1 2]) == 0 & num ~= 0 );
    temp=rec.var(v).data(range,:,:);
    temp(list) = con(list) ./ num(list);
    rec.var(v).data(range,:,:)=temp;
  end
  progress(size(rec.var(v).data,1),size(rec.var(v).data,1));
end

