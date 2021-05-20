function alph=get_alpha(mask,nband,refinecoeff);
%
% Create a parameter (alpha) such that it is 1 at
% the open boundaries and 0 after nband points.
% The all 4 boundaries are considerate open; this
% is the landmask that defines the closed boundaries.
%
% alpha is set to 1 for the 2 first parent points
% for the 2 way nesting
%
% Pierrick Penven & Laurent Debreu 2004
%
[M,L]=size(mask);
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
% identical parent grid bathymetry in the first 2 parent cells
%
%nbandfixed = 1+2*refinecoeff;
nbandfixed = 1.5+1.5*refinecoeff;
nbandtot = nbandfixed+nband;
%
% Cosine or linear alpha variations
%
alph=0.5*(cos(pi*(dist-nbandfixed)/nband)+1);
%alph=(nbandtot-dist)/nband;
%
alph(dist<nbandfixed)=1;
alph(dist>nbandtot)=0;
return
