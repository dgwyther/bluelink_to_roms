function [h_child,alph]=connect_topo(h_child,h_parent,h_coarse,...
                                      mask,mask_coarse,...
                                      pm_coarse,pn_coarse,pm_child,pn_child,...
                                      nband,refinecoeff,matchvolume)
%
%  Connect smoothly the child topography to the parent one
%  
% Pierrick Penven 2004
%
%
% 1 - get the alpha parameter (1=parent, 0=child)
%
alph=get_alpha(mask,nband,refinecoeff);
%
% 2 - correct parent topography in order to get the same volume
%     and the same section at the parent-child boundaries
%
if matchvolume==1
  h_parent=connect_volume(h_parent,h_coarse,mask_coarse,...
                          pm_coarse,pn_coarse,...
                          pm_child,pn_child,refinecoeff);
end
%
% 3 - mix the parent and the child topographies
%
h_child=alph.*h_parent+(1-alph).*h_child;
%
return
