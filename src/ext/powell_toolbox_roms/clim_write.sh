#!/usr/bin/env bash

name=$1
xi=$2
eta=$3
s=$4
num=$5

cat << EOF >| $name.cdl
netcdf $name {
dimensions:
        xi_rho = $xi ;
        xi_u = $((xi - 1)) ;
        xi_v = $xi ;
        eta_rho = $eta ;
        eta_u = $eta ;
        eta_v = $((eta - 1)) ;
        s_rho = $s ;
        s_w = $((s + 1)) ;
        tracer = 2 ;
        zeta_time = $num ;
        v2d_time = $num ;
        v3d_time = $num ;
        temp_time = $num ;
        salt_time = $num ;
variables:
        double zeta_time(zeta_time) ;
                zeta_time:long_name = "free-surface climatology time" ;
                zeta_time:field = "time, scalar, series" ;
        double zeta(zeta_time, eta_rho, xi_rho) ;
                zeta:long_name = "free-surface" ;
                zeta:units = "meter" ;
                zeta:time = "zeta_time" ;
                zeta:coordinates = "lat_rho lon_rho" ;
                zeta:field = "free-surface, scalar, series" ;
        double v2d_time(v2d_time) ;
                v2d_time:long_name = "2D-velocity climatology time" ;
                v2d_time:field = "time, scalar, series" ;
        double ubar(v2d_time, eta_u, xi_u) ;
                ubar:long_name = "vertically integrated u-momentum component" ;
                ubar:units = "meter second-1" ;
                ubar:time = "v2d_time" ;
                ubar:coordinates = "lat_u lon_u" ;
                ubar:field = "ubar-velocity, scalar, series" ;
        double vbar(v2d_time, eta_v, xi_v) ;
                vbar:long_name = "vertically integrated v-momentum component" ;
                vbar:units = "meter second-1" ;
                vbar:time = "v2d_time" ;
                vbar:coordinates = "lat_v lon_v" ;
                vbar:field = "vbar-velocity, scalar, series" ;
        double v3d_time(v3d_time) ;
                v3d_time:long_name = "3D-velocity climatology time" ;
                v3d_time:field = "time, scalar, series" ;
        double u(v3d_time, s_rho, eta_u, xi_u) ;
                u:long_name = "u-momentum component" ;
                u:units = "meter second-1" ;
                u:time = "v3d_time" ;
                u:coordinates = "lat_u lon_u" ;
                u:field = "u-velocity, scalar, series" ;
        double v(v3d_time, s_rho, eta_v, xi_v) ;
                v:long_name = "v-momentum component" ;
                v:units = "meter second-1" ;
                v:time = "v3d_time" ;
                v:coordinates = "lat_v lon_v" ;
                v:field = "v-velocity, scalar, series" ;
        double temp_time(temp_time) ;
                temp_time:long_name = "temperature climatology time" ;
                temp_time:field = "time, scalar, series" ;
        double temp(temp_time, s_rho, eta_rho, xi_rho) ;
                temp:long_name = "potential temperature" ;
                temp:units = "Celsius" ;
                temp:time = "temp_time" ;
                temp:coordinates = "lat_rho lon_rho" ;
                temp:field = "temperature, scalar, series" ;
        double salt_time(salt_time) ;
                salt_time:long_name = "salt climatology time" ;
                salt_time:field = "time, scalar, series" ;
        double salt(salt_time, s_rho, eta_rho, xi_rho) ;
                salt:long_name = "salinity" ;
                salt:time = "salt_time" ;
                salt:coordinates = "lat_rho lon_rho" ;
                salt:field = "temperature, scalar, series" ;

// global attributes:
                :title = "Climatology File" ;
                :author = "Brian Powell" ;
                :type = "ROMS Initialization" ;
                :Conventions = "CF-1.0" ;
}
EOF

ncgen -b -o $name -k "64-bit-offset" -x $name.cdl
rm $name.cdl

