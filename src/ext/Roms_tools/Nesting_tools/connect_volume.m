function h_correc=connect_volume(h_parent,h_coarse,mask_coarse, ...
                                 pm_coarse,pn_coarse,...
                                 pm_child,pn_child,refinecoeff)
%
% Correct parent topography in order to get the same volume
%  and the same cross-sections at the parent-child boundaries.
%
% Laurent Debreu & Pierrick Penven 2004
%
disp(' ')
disp(' Connect the volume...')
[M,L]=size(mask_coarse);
di=refinecoeff/2.-0.5;
iint = 1.+di;
%
correct_volume=1;
correct_vsurf=1;
correct_usurf=1;
%
if correct_volume==1
  err_vol=1.;
else
  err_vol=0.;
end
if correct_vsurf==1
  err_vsurf=1.;
else
  err_vsurf=0.;
end
if correct_usurf==1
  err_usurf=1.;
else
  err_usurf=0.;
end
%
epsilon=1e-15;
n=0;
h_correc=h_parent;
%
% Loop until convergence
%
while ((err_vol+err_vsurf+err_usurf) > epsilon)
  n=n+1;
%  disp(['iteration : ',num2str(n)])
  if correct_volume==1
%
% 1 - correct the volume (h*dx*dy)
%
% 1.1 : get the volume of the parent cell (i.e. get the coarse
%      value of h*dx*dy at  each parent RHO-points)
%
  volparent=mask_coarse(1+iint:refinecoeff:M-iint,1+iint:refinecoeff:L-iint).*...
            h_coarse(1+iint:refinecoeff:M-iint,1+iint:refinecoeff:L-iint)./...
	    (pm_coarse(1+iint:refinecoeff:M-iint,1+iint:refinecoeff:L-iint).*...
	     pn_coarse(1+iint:refinecoeff:M-iint,1+iint:refinecoeff:L-iint));
%
% 1.2 : get the total volume of the child cells corresponding to each parent cell
%
  volchild=0.*volparent;
  for j=-di:di
    for i=-di:di
      volchild=volchild+...
               h_correc(1+iint+j:refinecoeff:M-iint+j,1+iint+i:refinecoeff:L-iint+i)./...
	       (pm_child(1+iint+j:refinecoeff:M-iint+j,1+iint+i:refinecoeff:L-iint+i).*...
	        pn_child(1+iint+j:refinecoeff:M-iint+j,1+iint+i:refinecoeff:L-iint+i));
    end
  end
%
  volchild(volparent==0)=1;
  volparent(volparent==0)=1;
%
% 1.3 : apply the correction to h at  each parent RHO-points
%
  err=0.*volparent;
  for j=-di:di
    for i=-di:di
      err=err+...
         (h_correc(1+iint+j:refinecoeff:M-iint+j,1+iint+i:refinecoeff:L-iint+i).*...
	 (1.-volparent./volchild)).^2;
      h_correc(1+iint+j:refinecoeff:M-iint+j,1+iint+i:refinecoeff:L-iint+i)=...
             h_correc(1+iint+j:refinecoeff:M-iint+j,1+iint+i:refinecoeff:L-iint+i).*...
             volparent./volchild;
    end
  end
  err_vol=sum(sum(err));
%  disp(['err_volume = ',num2str(err_vol)]);
  end
  if correct_vsurf==1
%
% 2 - correct the surface at V points (h*dx)
%
% 2.1 : get the vertical areas for each parent V-points
%
  vsurfparent=mask_coarse(1:refinecoeff:M-1,1+iint:refinecoeff:L-iint).*...
              mask_coarse(2:refinecoeff:M,1+iint:refinecoeff:L-iint).*... 
              (h_coarse(1:refinecoeff:M-1,1+iint:refinecoeff:L-iint)+...
               h_coarse(2:refinecoeff:M,1+iint:refinecoeff:L-iint))./... 
              (pm_coarse(1:refinecoeff:M-1,1+iint:refinecoeff:L-iint)+...
               pm_coarse(2:refinecoeff:M,1+iint:refinecoeff:L-iint));
%
% 2.2 : get the equivalent areas for the child grid
%
  vsurfchild=0.*vsurfparent;
  for i=-di:di
    vsurfchild=vsurfchild+...
               (h_correc(1:refinecoeff:M-1,1+iint+i:refinecoeff:L-iint+i)+...
                h_correc(2:refinecoeff:M,1+iint+i:refinecoeff:L-iint+i))./... 
               (pm_child(1:refinecoeff:M-1,1+iint+i:refinecoeff:L-iint+i)+...
                pm_child(2:refinecoeff:M,1+iint+i:refinecoeff:L-iint+i));
  end
%
  vsurfchild(vsurfparent==0)=1;
  vsurfparent(vsurfparent==0)=1;
%
% 2.3 : apply the correction to h
%
  err=0.*vsurfparent;
  for j=0:1
    for i=-di:di
      err=err+(h_correc(1+j:refinecoeff:M-1+j,1+iint+i:refinecoeff:L-iint+i).*...
	       (1.-vsurfparent./vsurfchild)).^2;   
      h_correc(1+j:refinecoeff:M-1+j,1+iint+i:refinecoeff:L-iint+i)=...   
         h_correc(1+j:refinecoeff:M-1+j,1+iint+i:refinecoeff:L-iint+i).*...
         vsurfparent./vsurfchild;
    end
  end
  err_vsurf=sum(sum(err));
%  disp(['err_vsurf = ',num2str(err_vsurf)]);
  end
  if correct_usurf==1
%
% 3 - correct the surface at U points (h*dy)
%
% 3.1 : get the vertical areas for each parent U-points
%
  usurfparent=mask_coarse(1+iint:refinecoeff:M-iint,1:refinecoeff:L-1).*...
              mask_coarse(1+iint:refinecoeff:M-iint,2:refinecoeff:L).*...
              (h_coarse(1+iint:refinecoeff:M-iint,1:refinecoeff:L-1)+...
               h_coarse(1+iint:refinecoeff:M-iint,2:refinecoeff:L))./...
              (pn_coarse(1+iint:refinecoeff:M-iint,1:refinecoeff:L-1)+...
               pn_coarse(1+iint:refinecoeff:M-iint,2:refinecoeff:L));;
%
% 3.2 : get the equivalent areas for the child grid
%
  usurfchild=0.*usurfparent;
  for j=-di:di
    usurfchild=usurfchild+...
               (h_correc(1+iint+j:refinecoeff:M-iint+j,1:refinecoeff:L-1)+...
	        h_correc(1+iint+j:refinecoeff:M-iint+j,2:refinecoeff:L))./...
               (pn_child(1+iint+j:refinecoeff:M-iint+j,1:refinecoeff:L-1)+...
	        pn_child(1+iint+j:refinecoeff:M-iint+j,2:refinecoeff:L));
  end
%
  usurfchild(usurfparent==0)=1;
  usurfparent(usurfparent==0)=1;
%
% 3.3 : apply the correction to h
%
  err=0.*usurfparent;
  for j=-di:di
    for i=0:1
      err=err+(h_correc(1+iint+j:refinecoeff:M-iint+j,1+i:refinecoeff:L-1+i).*...
	       (1.-usurfparent./usurfchild)).^2;   
      h_correc(1+iint+j:refinecoeff:M-iint+j,1+i:refinecoeff:L-1+i)=...   
         h_correc(1+iint+j:refinecoeff:M-iint+j,1+i:refinecoeff:L-1+i).*...
         usurfparent./usurfchild;
    end
  end
  err_usurf=sum(sum(err));
%  disp(['err_usurf = ',num2str(err_usurf)]);
  end
  if n>200
    error(['connect_volume.m : no convergence after ',num2str(n),' iterations'])
  end
end
disp(['Connect volume : ',num2str(n),' iterations']);
return
