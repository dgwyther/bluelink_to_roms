# Toolbox for making forcing conditions from BRAN2020 output
## Credits
Brian Powell (for original toolboxes and conversion functions)

Colette Kerry (for coding all of the BRAN2016 scripts)

David Gwyther (minor editing to update to BRAN2020)

## Contents

## Procedure
1. (To update) Write the history file using `bluelink_load_his_new.m` 
2. Use `make_BL_clim_new.m` to write the clim files on the ROMS grid.
3. Use clim files to make the IC with `make_BL_ini_clim_new.m`
4. Use clim files to make the BC with `make_BL_bry_clim_new.m`

## Structure

docs                     -  important pdfs, manuals etc
src/
   |- bluelink_to_roms/  - the main code trunk
   |- ext/               - externally managed codes, scripts and functions
