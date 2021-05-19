function f = nanfft(x, varargin)

% function f = nanfft(x, varargin)
% This function just calls fft without any nan's in the x variable

f = fft(x(find(~isnan(x))), varargin{:});