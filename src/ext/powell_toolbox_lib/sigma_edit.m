function l = sigma_edit(data,factor)

% sigma_edit(data,factor,sublist)
% Return a list of values that are within two sigma of the dataset
% given.  factor defaults to 2.

f=2;

if nargin > 1
  f = factor;
end

d = reshape(data,1,size(data,1)*size(data,2));
l = find( abs(d) < ( abs(nanmean(d)) + f*nanstd(d) ) );
