#!/usr/bin/env python
import sys
import numpy as np
import netCDF4
import pyproj

def load_latlon(path):

    with netCDF4.Dataset(path) as nc_file:
        lat = nc_file.variables['lat'][:]
        lon = nc_file.variables['lon'][:]

    return lat, lon

def calculate_latlon(path):
    with netCDF4.Dataset(path) as nc_file:
        x = nc_file.variables['ni'][:]
        y = nc_file.variables['nj'][:]

        geo_var = nc_file.variables['geostationary']

        latitude_of_projection_origin  = geo_var.latitude_of_projection_origin
        longitude_of_projection_origin = geo_var.longitude_of_projection_origin
        perspective_point_height       = geo_var.perspective_point_height
        false_easting                  = geo_var.false_easting
        false_northing                 = geo_var.false_northing
        sweep_angle_axis               = geo_var.sweep_angle_axis

    p = pyproj.Proj(proj='geos', h=perspective_point_height, lon_0=longitude_of_projection_origin, sweep=sweep_angle_axis, datum='WGS84')

    X, Y = np.meshgrid(x*perspective_point_height, y*perspective_point_height)

    lon, lat = p(X, Y, inverse=True)

    # fill space pixels with NANs
    lon[np.abs(lon) > 360.0] = np.nan
    lat[np.abs(lat) > 90.0]  = np.nan

    return lat, lon

def add_latlon(path):
    lat, lon = calculate_latlon(path)

    with netCDF4.Dataset(path, mode='a') as nc_file:
        if 'lat' in nc_file.variables or 'lon' in nc_file.variables:
            print('file already has lat/lon variables')
            return

        lat_var = nc_file.createVariable('lat', np.float32, dimensions=('nj', 'ni'))
        lon_var = nc_file.createVariable('lon', np.float32, dimensions=('nj', 'ni'))

        lat_var.long_name = 'latitude'
        lat_var.standard_name = 'latitude'
        lat_var.units = 'degrees_north'
        lat_var.coordinates = 'nj ni'
        lat_var.valid_max = float(90.0)
        lat_var.valid_min = float(-90.0)

        lon_var.long_name = 'longitude'
        lon_var.standard_name = 'longitude'
        lon_var.units = 'degrees_east'
        lon_var.coordinates = 'nj ni'
        lon_var.valid_max = float(180.0)
        lon_var.valid_min = float(-180.0)

        lat_var[:, :] = lat.astype(np.float32)
        lon_var[:, :] = lon.astype(np.float32)

if __name__=='__main__':
    if len(sys.argv) < 2:
        print('usage: {} [gds2 granule]'.format(sys.argv[0]))
    else:
        add_latlon(sys.argv[1])
