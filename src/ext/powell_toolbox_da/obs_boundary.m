function obs = obs_boundary(obs, grid, width)
%   OBS_BOUNDARY   Remove observations from around the boundary
%     OBS = OBS_BOUNDARY(OBS, GRID, WIDTH)
% 
%   Because observations right on the boundary are inneffective, this
%   routine will remove observations within 'width' of the boundaries.
%   
%   Created by Brian Powell on 2009-08-20.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.


if nargin < 3
  width=1;
end
if nargin < 2
  error('You must specify obs and a grid.');
end

x=floor(obs.x)+1;
y=floor(obs.y)+1;

% First, take care of rho-points
maxj=grid.mp-width;
maxi=grid.lp-width;
l=find(obs.type==1 | obs.type > 5);
m=find(x(l)<width | x(l)>maxi | y(l)<width | y(l)>maxj);
if (~isempty(m))
  obs.value(l(m))=nan;
end

% Next, deal with u-points
maxj=grid.mp-width;
maxi=grid.l-width;
l=find(obs.type==2 | obs.type == 4);
m=find(x(l)<width | x(l)>maxi | y(l)<width | y(l)>maxj);
if (~isempty(m))
  obs.value(l(m))=nan;
end

% Finally, deal with v-points
maxj=grid.m-width;
maxi=grid.lp-width;
l=find(obs.type==3 | obs.type == 5);
m=find(x(l)<width | x(l)>maxi | y(l)<width | y(l)>maxj);
if (~isempty(m))
  obs.value(l(m))=nan;
end

% Strip out the nan's
l=find(~isnan(obs.value));
obs=delstruct(obs,l,length(obs.value));

end %  function