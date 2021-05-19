function c = nancorrcoef(a, b)

% function c = nancorrcoef(a, b)
%
% Compute the correlation coefficient from datasets containing nan's
% SEE ALSO: corrcoef
if ( nargin ~= 2 )
  error('You must supply two arguments.');
end

l = find( ~isnan( a .* b ) );
if ( isempty(l) )
  c = ones(2,2)*nan;
else
  c = corrcoef(a(l),b(l));
end

if ( length(c) < 2 )
  cc = ones(2,2)*nan;
  cc(1,2) = c;
  cc(2,1) = c;
  c=cc;
end
