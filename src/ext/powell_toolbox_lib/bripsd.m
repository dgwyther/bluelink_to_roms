function [f, p] = bripsd(sig, bins, sampling)

% function [f, p] = psd(sig, bins, [sampling])
%
% Given a signal and the number of bins (must be even), calculate the psd
% Optionally, the sampling can be specified (in Hz) such that the 
% returned frequency is in the correct units of Hertz.
%
% Returns: f as the frequency and p as the power
%
% by: Brian Powell
% (c) 2004, University of Colorado
%
% Example: You have a signal (y) of 1000 samples taken at 10 Hz, and you 
%   want to understand how the power is distributed:
%     [f,p] = psd(y,512,10);   % Generate the distribution
%     plot(f,p)                % View the results as Counts versus Frequency (Hz)

if ( nargin < 3)
  sampling = 1;
end

y=fft(sig,bins);
p=y.*conj(y)/bins;
p=p(1:bins/2);
f=transpose((0:bins/2-1)/bins * sampling);
