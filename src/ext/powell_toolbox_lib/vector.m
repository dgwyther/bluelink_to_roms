function v = vector( v )

% v = vector( v )
%
% No matter the shape of v, return it as a vector. This function is
% needed for the times that matrices are constructed and you wish to inline
% them as functions when you cannot vectorize them immediately.
%
% Example:
%  a = vector(nc_varget(file, 'matrix'));
v=v(:);
