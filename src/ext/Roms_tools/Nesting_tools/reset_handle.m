function handles=reset_handle(fig,handles)
%
% Put all the handles.XX objects to their default values
%
% Pierrick Penven 2004
%
handles.toponame=[];
handles.parentgrid=[];
handles.childgrid=[];
handles.parentfrc=[];
handles.childfrc=[];
handles.parentini=[];
handles.childini=[];
handles.parentclm=[];
handles.childclm=[];
handles.parentrst=[];
handles.childrst=[];
handles.lonmin=[];
handles.lonmax=[];
handles.latmin=[];
handles.latmax=[];
handles.imin=[];
handles.imax=[];
handles.jmin=[];
handles.jmax=[];
handles.rcoeff=3;
handles.Lparent=[];
handles.Mparent=[];
handles.Lchild=[];
handles.Mchild=[];
handles.rfactor=0.2;
handles.nband=15;
handles.hmin=[];
handles.newtopo=0;
handles.matchvolume=0;
handles.vertical_correc=0;
handles.extrapmask=0;
handles.biol=0;
handles.Isrcparent=[];
handles.Jsrcparent=[];
handles.Isrcchild=[];
handles.Jsrcchild=[];
guidata(fig, handles);
return
