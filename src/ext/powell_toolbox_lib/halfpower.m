function hp = halfpower(s)

% Compute the halfpower of the given filter, s
% Returns the halfpower period. Multiply by your sampling.
% e.g. if your sample is daily, and it returns 30, it is a 30day
len = 10000;
flist=[1:len]/len';
f=fft(s,length(flist));
tmp=abs(.5-abs(f));
hp=min(find(tmp==min(tmp)));
hp=1/flist(hp);

