function handles=interp_forcing(h,handles);
%
% Get everything in order to compute the child forcing file
%
% Pierrick Penven 2004
%
if isempty(handles.parentgrid)
  handles=get_parentfrcname(h,handles);
end
if isempty(handles.childgrid)
  handles=get_childgrdname(h,handles); 
end
if isempty(handles.parentfrc)
  handles=get_parentfrcname(h,handles);
end
lev=str2num(handles.parentfrc(end));
if isempty(lev)
  childname=[handles.parentfrc,'.1'];
else
  childname=[handles.parentfrc(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child forcing name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childfrc=childname;
end
nested_forcing(handles.childgrid,handles.parentfrc,handles.childfrc)
return
