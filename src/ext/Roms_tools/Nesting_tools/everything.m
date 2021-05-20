function handles=everything(h,handles);
%
% Perform every steps to generate a child model:
% grid, forcing, initial, clim, restart
%
% Pierrick Penven 2004
%
 handles=interp_child(h,handles);
 handles=interp_forcing(h,handles);
 handles=interp_initial(h,handles);
 handles=interp_clim(h,handles);
 handles=interp_restart(h,handles);
 return
