function var3d=tridim(var2d,N)

[M,L]=size(var2d);
var3d=reshape(var2d,1,M,L);
var3d=repmat(var3d,[N 1 1]);
return
  
