function m = trimmean(x)

% function m = trimmean(x)
%
% Given a matrix, remove the trim mean in a row-wise orientation

s = size(x);
t = nanmean(x')';
t = t(:,ones(1,s(2)));
m = x - t;