function [temp, salt] = interp_density(tempo,salto,deptho,grid)

% INTERP_DENSITY   Vertically interpolate temp and salt
%
% Using density to ensure stratification, interpolate temperature
% and salt
% 
% SYNTAX
%   [TEMPI, SALTI] = INTERP_DENSITY(TEMP,SALT,DEPTH,GRID)
% 

%
% Created by Brian Powell on 2007-11-27.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<4)
  error('missing arguments');
end

depths = grid_depth(grid);
depths(1:end-1,:,:)=(depths(1:end-1,:,:)-depths(2:end,:,:))/2 + depths(2:end,:,:);
depths(end,:,:)=depths(end,:,:)/2;
ndep = size(depths,1);
wet=find(grid.maskr~=0);
mask = reshape(grid.maskr,[1 size(grid.maskr)]);
mask = mask(ones(ndep,1),:,:);
temp = depths*0;
salt = depths*0;

% Go through every point in the grid and interpolate
for c=1:length(wet),
  i=wet(c);
  nl=deptho;
  nt=tempo(:,i);
  ns=salto(:,i);
  i1 = find(-diff([0;nl]) > 0.01 & nt>1e-2 & nt<35 & ns>1e-2 & ns<40);
  if (isempty(i1)) continue; end
  nl=nl(i1); nt=nt(i1); ns=ns(i1);
%  if ( nl(end) < -4000 )
%    nt(end)=nanmean(nt(end-1:end));
%    ns(end)=nanmean(ns(end-1:end));
%  end
  nl = [0.; nl; depths(1,i)-1000]; 
  nt=[nt(1); nt; nt(end)*.92];
  ns=[ns(1); ns; ns(end)*.98];
  temp(:,i) = interp1(nl,nt,depths(:,i));
  salt(:,i) = interp1(nl,ns,depths(:,i));
  % % Do the vertical interpolation
  % l=find(tempo(:,i)>1e-2 & tempo(:,i) < 35 & salto(:,i)>1e-2 & salto(:,i) <= 37);
  % if ( length(l)>2 )
  %   temp(:,i) = spline(deptho(l),tempo(l,i),depths(:,i));
  %   salt(:,i) = spline(deptho(l),salto(l,i),depths(:,i));
  % end
  % 
  % % Check the interp
  % if ( (max(temp(:,i))>max(tempo(l,i))) | (min(temp(:,i))<min(tempo(l,i))) | ...
  %      (max(salt(:,i))>max(salto(l,i))) | (min(salt(:,i))<min(salto(l,i))) )
  %   to=[  tempo(l(1),i);  tempo(l,i)];
  %   so=[  salto(l(1),i);  salto(l,i)];
  %   do=[ max(0,max(deptho(l))+1); deptho(l); ];
  %   if (do(end) > depths(1,i) ) 
  %     do(end+1) = depths(1,i)*1.1;
  %     so(end+1) = so(end);
  %     to(end+1) = to(end);
  %   end
  %   temp(:,i) = interp1(do,to,depths(:,i));
  %   salt(:,i) = interp1(do,so,depths(:,i));
  % end

  % Clean up the interpolation, if we are in deep water
  % if ( depths(1,i) > -100 ) continue; end
  % 
  % count=1;
  % unstable=true;
  % while ( unstable & count < length(deptho) )
  %   rho = sw_dens0(salt(:,i),temp(:,i));
  %   l=find(~isnan(rho));
  %   d=diff(rho(l));
  %   l=l(find(d>0));
  %   if (isempty(l))
  %     unstable=true;
  %     break;
  %   end
  %   temp(l,i) = nan;
  %   salt(l,i) = nan;
  %   count = count + 1;
  % end
  % l=find(~isnan(temp(:,i)) | ~isnan(salt(:,i)))';
  % if ( length(l) < ndep)
  %   % Fix endpoint issues
  %   if (isnan(temp(1,i)) | isnan(salt(1,i)))
  %     temp(1,i)=temp(min(find(~isnan(temp(:,i)))),i);
  %     salt(1,i)=salt(min(find(~isnan(salt(:,i)))),i);
  %   end
  %   if (isnan(temp(end,i)) | isnan(salt(end,i)))
  %     temp(end,i)=temp(max(find(~isnan(temp(:,i)))),i);
  %     salt(end,i)=salt(max(find(~isnan(salt(:,i)))),i);
  %   end
  %   l=unique([1 l ndep]);
  %   temp(:,i) = interp1(depths(l,i),temp(l,i),depths(:,i));
  %   salt(:,i) = interp1(depths(l,i),salt(l,i),depths(:,i));
  % end
end
temp=temp.*mask;
salt=salt.*mask;
