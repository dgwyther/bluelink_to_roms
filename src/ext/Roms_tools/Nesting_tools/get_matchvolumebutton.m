function handles=get_matchvolumebutton(h,handles);
%
% Button to set wether or not the parent child volume 
% matching procedure is on or not.
%
% Pierrick Penven 2004
%
if handles.matchvolume==0
  handles.matchvolume = 1;
else
  handles.matchvolume = 0;
end
return
