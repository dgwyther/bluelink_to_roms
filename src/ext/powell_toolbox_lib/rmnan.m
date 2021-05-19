function a = rmnan(b)

% function a = rmnan(b)
%
% Given a matrix of data, b, return a new matrix without any NaN's present.
% If the matrix is a vector, only the NaN entries will be removed.

a=b;
[n,m] = size(a);
if ( n == 1 | m == 1 )
  a(isnan(a))=[];
else
  a(any(isnan(a)'),:)=[];
end
