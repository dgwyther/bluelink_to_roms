function v = godelnumber(a)

%
% v = godelnumber(a)
%
% return a vector of godel numbers constructed from the matrix a
%
exponent = primes(size(a,2)*10);
exponent = exponent(1:size(a,2));
v = prod(exponent(ones(size(a,1),1),:).^abs(a),2);
