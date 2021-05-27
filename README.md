# Toolbox for making forcing conditions from BRAN2020 output
## Credits
Brian Powell (for original toolboxes and conversion functions)

Colette Kerry (for coding all of the BRAN2016 scripts)

David Gwyther (update to BRAN2020 and toolbox-ify this process)

## Pre-requisites
- matlab (tested on R2019b)
- netcdf4

## Procedure
1. Set the options in the conf file: `conf/set_default_options.m`.
2. Make the ''BL grid file'', which is just a subset of the lat/lon grid that covers the specified ROMS grid.
3. Write the history file using `bluelink_load_his_new.m`. Ensure settings in conf file are correct.
4. Use `make_BL_clim_new.m` to write the clim files on the ROMS grid.
n.b. Steps 3. and 4. are very time consuming. I recommend you use pre-existing outputs from these steps, which have already been calculated for 1994-2019 for the EAC domain. A different model grid/domain will require re-calculation of these outputs.
5. Use clim files to make the IC with `make_BL_ini_clim_new.m`
6. Use clim files to make the BC with `make_BL_bry_clim_new.m`

## Structure
```
.
|-- conf                                           - configuration options
|   `-- set_default_options.m
|-- data                                           - output directory for temporary and final data
|   |-- final
|   `-- out
|-- docs                                           - important pdfs, manuals, etc
|-- src                                            - all repository source code
|   |-- bluelink_to_roms                           - *source code for this converting bluelink to roms*
|   |   |-- BL_roms_grid.m
|   |   |-- bluelink_load_his_new.m
|   |   |-- make_BL_bry_clim_new.m
|   |   |-- make_BL_clim_new.m
|   |   |-- make_BL_gridsubset.m
|   |   |-- make_BL_ini_clim_new.m
|   |   `-- zlev_to_roms_clim_BlueLink_EACgrid.m
|   `-- ext                                        - external toolboxes, code, scripts and functions
`-- README.md
```
