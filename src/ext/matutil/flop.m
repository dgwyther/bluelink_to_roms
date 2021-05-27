function n = flop
%FLOP Read the flop counter.
%
%   FLOP, by itself, prints the number of flops since FLIP was used.
%   n = FLOP; saves the flop count in n, instead of printing it out.
%
%   See also FLIP, FLOPS, TIC, TOC.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:19:58 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

% FLOP uses the value of FLOPS saved by FLIP.
global FLIPFLOP
if isempty(FLIPFLOP)
  error('You must call FLIP before calling FLOP.');
end
if nargout < 1
   flop_count = flops - FLIPFLOP
else
   n = flops - FLIPFLOP;
end
