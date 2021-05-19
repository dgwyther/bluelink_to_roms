function [lo,hi,m] = extreme_members(x)

% EXTREME_MEMBERS   Return the 5% and 95% member of the distribution
%
% For ensembles, we want to find the 5% and 95% members. This function,
% given a set of data finds these and returns their indices
% 
% SYNTAX
%   [LO,HI,M] = EXTREME_MEMBERS(X)
% 

%
% Created by Brian Powell on 2008-04-26.
% Copyright (c)  powellb. All rights reserved.
%

if ( nargin < 1 )
  error('you must specify data');
end

% If they sent a matrix, we'll find the average members
if ( ~isvector(x) )
  % If there are rows with all nan's, ignore
  l=find(~isnan(nansum(x')));
  x=x(l,:);

  % Throw out any member with at least 20% nan values
  xn=sum(isnan(x)',2);
  x(:,find(xn>=0.2*size(x,1)))=nan;
  x=nanmean(x);
end

% Throw out each extreme member
x(find(x==nanmax(x)))=nan;
x(find(x==nanmin(x)))=nan;

m=nanmean(x);
s=2*nanstd(x);

l=find( x<=m-s );
if (isempty(l))
  lo=find(x==nanmin(x));
else
  lo=l(find(x(l)==nanmax(x(l))));
end

l=find( x>=m+s );
if (isempty(l))
  hi=find(x==nanmax(x));
else
  hi=l(find(x(l)==nanmin(x(l))));
end



