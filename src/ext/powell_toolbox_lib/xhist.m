function h = xhist(a,b,binsize,minbin,maxbin)

% h = xhist(a,b,binsize,minbin,maxbin)
% Create a histogram between two sets of data
% a and b must be the same size
% a is the binning parameter
% b is the data to bin

%-----------------------------------------------
% Make sure they gave us a filename
error(nargchk(2,5,nargin));

last = ceil(max(a));
first = floor(min(a));

if nargin >= 4
  first = minbin;
end
if nargin == 5
  last = maxbin;
end
if nargin < 3
  bsize=(last-first)/10;
else
  bsize = binsize;
end

bins = zeros(ceil((last-first)/bsize+1), 1);

index = 1;
for j=first:bsize:last+bsize,
  vals = find(a >= j & a < j+bsize);
  if ( size(vals,1) > 0 )
    bins(index) = nanmean(b(vals));
  end
  index = index + 1;
end 

t=[first:bsize:last];
h=plot(t,bins([1:size(t,2)]));
