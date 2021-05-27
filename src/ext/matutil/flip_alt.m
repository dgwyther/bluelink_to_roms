function flip
%FLIP Start a flop counter.
%
%   The sequence of commands
%       FLIP, operation, FLOP
%   prints the number of flops required for the operation.
%
%   See also FLOP, FLOPS, TIC, TOC.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:19:34 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

% FLIP simply stores FLOPS in a global variable.
global FLIPFLOP
FLIPFLOP = flops;
