function potT=theta(S,T,P)
%
%  Pierrick 2004
%
% potT=theta(S,T,P)
%
% Description: Compute potential temperature of seawater.
%
% This routine is derived from Dan Kelley's program : oce.theta.c 
% http://www.phys.ocean.dal.ca/~kelley/
%
% Usage: potT=theta(S,T,P)
%
% Arguments:
%            S in-situ salinity [PSU]
%            T in-situ temperature [degC]
%            P in-situ pressure [dbar]
%
% Details:
% The potential temperature is defined to be the temperature that a 
% water parcel of the indicated properties would achieve if it were 
% moved adiabatically to the surface of the ocean.
%
% Value: Potential temperature [degC] referenced to the surface. 
%
% References:  
%             Fofonoff , P. and R. C. Millard Jr, 1983. Algorithms for 
%             computation of fundamental properties of seawater.  
%             Unesco Technical Papers in Marine Science, 44, 53 pp 
% 
%             Gill, A.E., 1982. Atmosphere-ocean Dynamics, Academic Press,  
%             New York, 662 pp.
%
% Example: theta(35, 13, 1000)=12.858
%
S = S-35.0;
T = T;
P = P./10.0;
potT = T ...
-P .* (((3.6504e-4+T.*(8.3198e-5+T.*(-5.4065e-7+T.*4.0274e-9)))...
        +S.*(1.7439e-5-T.*2.9778e-7))...
       +P.*((8.9309e-7+T.*(-3.1628e-8+T.*2.1987e-10)-S.*4.1057e-9)...
            +P.*(-1.6056e-10+T.*5.0484e-12)));
return
