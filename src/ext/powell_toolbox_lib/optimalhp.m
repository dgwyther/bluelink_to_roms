function [hp, e] = optimalhp(p, q, dt)

% function hp = halfpower(p, q, dt)
% Given p and q, Compute the halfpower width for T/P & Jason
%
% Written by Brian Powell (c) 2003, University of Colorado at Boulder
if ( nargin < 2 )
  error('Incorrect Arguments');
elseif ( nargin < 3 )
  dt = 1;
end

p=abs(p);
q=abs(q);

% Generate the weights
[w, e] = genweights(-p, q, dt);
width = length(w);
len = 10;
while ( ( width / len ) > 1 )
  len = len * 10;
end
len = len * 10;

% Construct the Equivalent weighting kernel
filt = [ -p:q ];
filt = abs([ filt(1:p) filt(p+2:end) ]);
weights = w' ./ filt;
filtwin = zeros(1, len);
split=find(filt(2:end) == filt(1:end-1));
if ( isempty(split) )
  if ( filt(1) > filt(end) )
    split = width;
  else
    split = 0;
  end
end
for j=2:split,
  weights(j) = weights(j) + weights(j-1);
end
if ( split < width )
  for j=width-1:-1:split+1,
    weights(j) = weights(j) + weights(j+1);
  end
end
filtwin((len/2)-split:(len/2)-split+width-1) = weights;
plot(filtwin);

% FFT the bad boy
flist = [1:len*100]/(len*100)';
good = find( flist > .01 & flist <= 0.5 );
f = fft(filtwin,length(flist));
tmp = abs(0.5 - abs(f));
hp = min(find(tmp == min(tmp)));
hp=5.7531*dt/flist(hp);
