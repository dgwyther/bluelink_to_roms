function b = collapse(a)
%COLLAPSE Remove singleton dimensions.
% Same as squeeze, but even if two-dimensional

if nargin==0 
  error('MATLAB:squeeze:NotEnoughInputs', 'Not enough input arguments.'); 
end

  siz = size(a);
  siz(siz==1) = []; % Remove singleton dimensions.
  siz = [siz ones(1,2-length(siz))]; % Make sure siz is at least 2-D
  b = reshape(a,siz);
