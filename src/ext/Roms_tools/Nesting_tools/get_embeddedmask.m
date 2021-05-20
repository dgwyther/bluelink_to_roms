  function mask=get_embeddedmask(mask_parent,h,refinecoeff,newtopo)
% 
%
% Pierrick Penven & Laurent Debreu 2004
%
if newtopo==1
  mask=h>0;
  [M,L]=size(mask);
%
  mask(1,:)=mask_parent(1,:);
  mask(end,:)=mask_parent(end,:);
  mask(:,1)=mask_parent(:,1);
  mask(:,end)=mask_parent(:,end);
% 
  [imat,jmat]=meshgrid((1:L),(1:M));
  dist=0*mask+inf;
  for j=1:M
    if mask(j,1)==1 
      dist=min(cat(3,dist,sqrt((imat-1).^2+(jmat-j).^2)),[],3);
    end
    if mask(j,L)==1 
      dist=min(cat(3,dist,sqrt((imat-L).^2+(jmat-j).^2)),[],3);
    end
  end
  for i=1:L
    if mask(1,i)==1 
      dist=min(cat(3,dist,sqrt((imat-i).^2+(jmat-1).^2)),[],3);
    end
    if mask(M,i)==1 
      dist=min(cat(3,dist,sqrt((imat-i).^2+(jmat-M).^2)),[],3);
    end
  end
%
% Put the parent mask close to the boundaries
%
  nmsk=1+2*refinecoeff;
  mask(dist<=nmsk)=mask_parent(dist<=nmsk);
else
  mask=mask_parent;
end
%
% Process the mask to check for points bays, et...
%
mask=process_mask(mask);
%
% in some cases the child mask can't be the same to the parent
% at the boundary:
%
if sum(mask(1,:)~=mask_parent(1,:))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the SOUTH boundary')
  disp('  You might want to deplace this boundary')
  disp(' ')
end
if sum(mask(end,:)~=mask_parent(end,:))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the NORTH boundary')
  disp('  You might want to deplace this boundary')
  disp(' ')
end
if sum(mask(:,end)~=mask_parent(:,end))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the EAST boundary')
  disp('  You might want to deplace this boundary')
  disp(' ')
end
if sum(mask(:,1)~=mask_parent(:,1))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the WEST boundary')
  disp('  You might want to deplace this boundary')
  disp(' ')
end
return
