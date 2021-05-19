function ang = topex_angle(lat)

% Given a latitude, return the angle of the satellite

nlat = lat * pi/180;
Re = 6378.1363;
a = 7725.6029;
% Keplerian
% Vs = ( Re / a ) * sqrt( 3.986012e5 / a );
% Precise
Vs = 2*pi*Re / ...
   ( 2*pi*sqrt(a^3/3.986012e5)*(1 - 1.5*(1.0826e-3)*(Re/a)^2*(4*(cos(deg2rad(66.0408)))^2-1)));
Ve = Re * 2*pi/86164.1;
alpha = asin( abs( cos( deg2rad(66.0408) ) ./ cos( nlat )));
ang = atan( abs( ( Vs*sin(alpha) - Ve*cos( nlat ) ) ./ ( Vs*cos(alpha) )));