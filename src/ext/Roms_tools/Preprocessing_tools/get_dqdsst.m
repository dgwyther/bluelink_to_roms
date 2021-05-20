function dqdsst=get_dqdsst(sst,sat,rho_atm,U,qsea)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
%  Compute the kinematic surface net heat flux sensitivity to the
%  the sea surface temperature: dQdSST.
%  Q_model ~ Q + dQdSST * (T_model - SST)
%  dQdSST = - 4 * eps * stef * T^3  - rho_atm * Cp * CH * U
%           - rho_atm * CE * L * U * 2353 * ln (10 * q_s / T^2)
% 
% Input parameters:
%
%  sst     : sea surface temperature (Celsius)
%  sat     : sea surface atmospheric temperature (Celsius)
%  rho_atm : atmospheric density (kilogram meter-3) 
%  U       : wind speed (meter s-1)
%  qsea    : sea level specific humidity
%
% 
% Ouput:
%
%  dqdsst  : kinematic surface net heat flux sensitivity to the
%            the sea surface temperature (Watts meter-2 Celsius-1)
%
%  Pierrick Penven, IRD, 2002.
%
%  Version of 2-Oct-2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Specific heat of atmosphere.
%
Cp = 1004.8;
%
%  Sensible heat transfert coefficient (stable condition)
%
Ch = 0.66e-3;
%
%  Latent heat transfert coefficient (stable condition)
%
Ce = 1.15e-3;
%
%  Emissivity coefficient
%
eps = 0.98;
%
%  Stefan constant
%
stef = 5.6697e-8;
%
%  SST (Kelvin)
%
SST = sst + 273.15;
%
%  Latent heat of vaporisation (J.kg-1)
%
L = 2.5008e6 - 2.3e3 * sat;
%
%  Infrared contribution
%
q1 = -4.d0 .* stef .* (SST.^3);
%
%  Sensible heat contribution
%
q2 = -rho_atm .* Cp .* Ch .* U;
%
%  Latent heat contribution
%
dqsdt = 2353.d0 .* log(10.d0) .* qsea ./ (SST.^2);
q3 = -rho_atm .* Ce .* L .* U .* dqsdt;
%
%  dQdSST
%
dqdsst = q1 + q2 + q3 ;

