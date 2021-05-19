function [b, i, j] = uniquerows(a)

% [b, i, j] = uniquerows(a)
%
% Find unique rows in the matrix a. Return variables are
% identical to 'unique'. This routine creates a Godel number
% for each row then calls matlab's unique

[b, i, j] = unique( godelnumber(a) );
