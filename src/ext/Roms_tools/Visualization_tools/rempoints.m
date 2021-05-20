function var=rempoints(var,npts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
%  function var=rempoints(var,npts)
%
%  crop the data to remove boundary values
%
% input:
%
%  var    data to proceed (2D matrix)
%  npts   points to remove (for values vector)
%         ex: [3 3 3 0] : [west east south north]
% output:
%
%  var    (2D matrix)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(var);
var=var(npts(3)+1:M-npts(4),npts(1)+1:L-npts(2));
return
