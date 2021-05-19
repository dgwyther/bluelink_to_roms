function s = delstruct( s, idx, len )

% s = delstruct( s, idx )
%
% This function replaces every record in the structure with only
% the elements in the idx vector
%

if ( nargin < 2 )
  error('You must specify two arguments')
end
if ( nargin < 3 )
  len = 0;
end

names = fieldnames(s);
for i=1:length(names),
  n=char(names(i));
  v=getfield(s,n);
  if ( len & length(v) ~= len ) continue; end
  s=setfield(s,n,v(idx));
end
