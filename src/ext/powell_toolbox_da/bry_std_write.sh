#!/usr/bin/env bash

name=$1
xi=$2
eta=$3
s=$4

if [[ ${xi} -gt ${eta} ]]; then
  iorj=${xi}
else
  iorj=${eta}
fi

cat << EOF >| $name.cdl
netcdf $name {
dimensions:
    xi_rho = $xi ;
    xi_u = $((xi - 1)) ;
    xi_v = $xi ;
    xi_psi = $((xi - 1)) ;
    eta_rho = $eta ;
    eta_u = $eta ;
    eta_v = $((eta - 1)) ;
    eta_psi = $((eta - 1)) ;
    IorJ = $iorj ;
    s_rho = $s ;
    s_w = $((s + 1)) ;
    tracer = 2 ;
    boundary = 4 ;
    ocean_time = UNLIMITED ; // (0 currently)

variables:
    int spherical ;
        spherical:long_name = "grid type logical switch" ;
        spherical:flag_values = 0, 1 ;
        spherical:flag_meanings = "Cartesian spherical" ;
    int Vtransform ;
        Vtransform:long_name = "vertical terrain-following transformation equation" ;
    int Vstretching ;
        Vstretching:long_name = "vertical terrain-following stretching function" ;
    double theta_s ;
        theta_s:long_name = "S-coordinate surface control parameter" ;
    double theta_b ;
        theta_b:long_name = "S-coordinate bottom control parameter" ;
    double Tcline ;
        Tcline:long_name = "S-coordinate surface/bottom layer width" ;
        Tcline:units = "meter" ;
    double hc ;
        hc:long_name = "S-coordinate parameter, critical depth" ;
        hc:units = "meter" ;
    double s_rho(s_rho) ;
        s_rho:long_name = "S-coordinate at RHO-points" ;
        s_rho:valid_min = 0. ;
        s_rho:valid_max = -1. ;
        s_rho:positive = "up" ;
        s_rho:standard_name = "ocean_s_coordinate_g1" ;
        s_rho:formula_terms = "s: s_rho C: Cs_r eta: zeta depth: h depth_c: hc" ;
    double s_w(s_w) ;
        s_w:long_name = "S-coordinate at W-points" ;
        s_w:valid_min = 0. ;
        s_w:valid_max = -1. ;
        s_w:positive = "up" ;
        s_w:standard_name = "ocean_s_coordinate_g1" ;
        s_w:formula_terms = "s: s_w C: Cs_w eta: zeta depth: h depth_c: hc" ;
    double Cs_r(s_rho) ;
        Cs_r:long_name = "S-coordinate stretching curves at RHO-points" ;
        Cs_r:valid_min = -1. ;
        Cs_r:valid_max = 0. ;
    double Cs_w(s_w) ;
        Cs_w:long_name = "S-coordinate stretching curves at W-points" ;
        Cs_w:valid_min = -1. ;
        Cs_w:valid_max = 0. ;
    double h(eta_rho, xi_rho) ;
        h:long_name = "bathymetry at RHO-points" ;
        h:units = "meter" ;
        h:coordinates = "x_rho y_rho" ;
    double lon_rho(eta_rho, xi_rho) ;
        lon_rho:long_name = "longitude of RHO-points" ;
        lon_rho:units = "degree_east" ;
        lon_rho:standard_name = "longitude" ;
    double lat_rho(eta_rho, xi_rho) ;
        lat_rho:long_name = "latitude of RHO-points" ;
        lat_rho:units = "degree_north" ;
        lat_rho:standard_name = "latitude" ;
    double lon_u(eta_u, xi_u) ;
        lon_u:long_name = "longitude of U-points" ;
        lon_u:units = "degree_east" ;
        lon_u:standard_name = "longitude" ;
    double lat_u(eta_u, xi_u) ;
        lat_u:long_name = "latitude of U-points" ;
        lat_u:units = "degree_north" ;
        lat_u:standard_name = "latitude" ;
    double lon_v(eta_v, xi_v) ;
        lon_v:long_name = "longitude of V-points" ;
        lon_v:units = "degree_east" ;
        lon_v:standard_name = "longitude" ;
    double lat_v(eta_v, xi_v) ;
        lat_v:long_name = "latitude of V-points" ;
        lat_v:units = "degree_north" ;
        lat_v:standard_name = "latitude" ;
    double angle(eta_rho, xi_rho) ;
        angle:long_name = "angle between XI-axis and EAST" ;
        angle:units = "radians" ;
        angle:coordinates = "lat_rho lon_rho" ;
        angle:field = "angle, scalar" ;
    double mask_rho(eta_rho, xi_rho) ;
        mask_rho:long_name = "mask on RHO-points" ;
        mask_rho:flag_values = 0., 1. ;
        mask_rho:flag_meanings = "land water" ;
        mask_rho:coordinates = "lon_rho lat_rho" ;
    double mask_u(eta_u, xi_u) ;
        mask_u:long_name = "mask on U-points" ;
        mask_u:flag_values = 0., 1. ;
        mask_u:flag_meanings = "land water" ;
        mask_u:coordinates = "lon_u lat_u" ;
    double mask_v(eta_v, xi_v) ;
        mask_v:long_name = "mask on V-points" ;
        mask_v:flag_values = 0., 1. ;
        mask_v:flag_meanings = "land water" ;
        mask_v:coordinates = "lon_v lat_v" ;
    double ocean_time(ocean_time) ;
        ocean_time:long_name = "days from beginning of year" ;
        ocean_time:units = "days" ;
    double zeta_obc(ocean_time, boundary, IorJ) ;
        zeta_obc:long_name = "free-surface open boundaries standard deviation" ;
        zeta_obc:units = "meter" ;
        zeta_obc:time = "ocean_time" ;
    double ubar_obc(ocean_time, boundary, IorJ) ;
        ubar_obc:long_name = "vertically integrated u-momentum component open boundaries standard deviation" ;
        ubar_obc:units = "meter second-1" ;
        ubar_obc:time = "ocean_time" ;
    double vbar_obc(ocean_time, boundary, IorJ) ;
        vbar_obc:long_name = "vertically integrated v-momentum component open boundaries standard deviation" ;
        vbar_obc:units = "meter second-1" ;
        vbar_obc:time = "ocean_time" ;
    double u_obc(ocean_time, boundary, s_rho, IorJ) ;
        u_obc:long_name = "u-momentum component open boundaries standard deviation" ;
        u_obc:units = "meter second-1" ;
        u_obc:time = "ocean_time" ;
    double v_obc(ocean_time, boundary, s_rho, IorJ) ;
        v_obc:long_name = "v-momentum component open boundaries standard deviation" ;
        v_obc:units = "meter second-1" ;
        v_obc:time = "ocean_time" ;
    double temp_obc(ocean_time, boundary, s_rho, IorJ) ;
        temp_obc:long_name = "potential temperature open boundaries standard deviation" ;
        temp_obc:units = "Celsius" ;
        temp_obc:time = "ocean_time" ;
    double salt_obc(ocean_time, boundary, s_rho, IorJ) ;
        salt_obc:long_name = "salinity open boundaries standard deviation" ;
        salt_obc:time = "ocean_time" ;

    // global attributes:
    :type = "ROMS/TOMS 4DVAR open boundary conditions error covariance standard deviation file" ;
    :boundary_index = "West=1, South=2, East=3, North=4" ;
    :Conventions = "CF-1.0" ;
    :title = "ROMS/TOMS 4D-Var Open Boundary Standard Deviation" ;
}
EOF

ncgen -b -o $name -k "64-bit-offset" -x $name.cdl
rm $name.cdl
