function gridded = obs_gridder( data, opt )

% gridded = obs_gridder( data, opt )
%
% This function takes an observed data structure and an options structure
%  with the grid information and places the data onto the grid
%

if ( nargin < 2 )
  error('You must specify two arguments');
end

n=numel(data.lon);
x=reshape(data.lon,n,1);
y=reshape(data.lat,n,1);
dx=opt.dlon ./ earth_distance([opt.lon(:) opt.lon(:)+1 opt.lat(:) opt.lat(:)]);
dy=opt.dlat ./ earth_distance([opt.lon(:) opt.lon(:) opt.lat(:) opt.lat(:)+1]);
dxy = dx .* sin(opt.angle(:));
dx  = dx .* cos(opt.angle(:));
dyx = dy .* sin(opt.angle(:));
dy  = dy .* cos(opt.angle(:));
xv = [ opt.lon(:)+(dx-dyx) opt.lon(:)+(dx+dyx) opt.lon(:)-(dx-dyx) opt.lon(:)-(dx+dyx) opt.lon(:)+(dx-dyx)];
yv = [ opt.lat(:)+(dy+dxy) opt.lat(:)-(dy-dxy) opt.lat(:)-(dy+dxy) opt.lat(:)+(dy-dxy) opt.lat(:)+(dy+dxy)];
% clf; plot(opt.lon(:),opt.lat(:),'+'); hold on; plot(xv(floor(length(xv)/2),:),yv(floor(length(xv)/2),:),'k-'); disp(length(xv));

mnlon=min(data.lon(:))-2*max(dx);
mxlon=max(data.lon(:))+2*max(dx);
mnlat=min(data.lat(:))-2*max(dy);
mxlat=max(data.lat(:))+2*max(dy);
search_list = find( xv(:,3)>=mnlon & xv(:,1) <= mxlon &  ...
                    yv(:,3)>=mnlat & yv(:,1) <= mxlat );
% clf; hold on; plot(opt.lon(:),opt.lat(:),'+');
% for i=1:length(search_list),
%   plot(xv(search_list(i),:),yv(search_list(i),:),'k-')
% end

if ( opt.is3d )
  opt.ddepths = reshape(opt.ddepths, 1, length(opt.ddepths));
  l=find(opt.ddepths>0);
  if ( ~isempty(l) )
    opt.ddepths(l)=-opt.ddepths(l);
  end
  opt.ddepths = sort(opt.ddepths,'descend');
end
gridded.time = [];
for v=1:length(opt.vars)
  gridded = setfield(gridded,char(opt.vars(v)),[]);
  gridded = setfield(gridded,[char(opt.vars(v)) '_v'],[]);
end
count = 1;
% for i=1:size(xv,1),
for s=1:length(search_list),
  i=search_list(s);
  pts = find(inpolygon(x,y,xv(i,:),yv(i,:)));
  if ( isempty(pts) ) continue; end
  % Go over all times
  dt=0;
  while ( dt(end)<length(pts) )
    cur=data.time(pts(dt(end)+1));
    dt(end+1)=max(find(data.time(pts)>=cur & data.time(pts)<cur+opt.dtime));
  end
  for ts=1:length(dt)-1,
    in = pts(dt(ts)+1:dt(ts+1));
    if ( opt.is3d )
      for z=2:length(opt.ddepths),
        l = in(find( data.depth(in) <= opt.ddepths(z-1) & ...
                     data.depth(in) >  opt.ddepths(z)));
        if ( ~isempty(l) )
          gridded.time(count,1) = nanmean(data.time(l));
          gridded.z(count,1) = nanmean(data.depth(l));
          gridded.lon(count,1) = nanmean(x(l));
          gridded.lat(count,1) = nanmean(y(l));
          gridded.num(count,1) = length(l);
          for v=1:length(opt.vars)
            fld=getfield(data,char(opt.vars(v)));
            fld=fld(l);
            nv=getfield(gridded,char(opt.vars(v)));
            nvv=getfield(gridded,[char(opt.vars(v)) '_v']);
            nv(count,1) = nanmean(fld(:));
            nvv(count,1) = nanvar(fld(:));
            gridded=setfield(gridded,char(opt.vars(v)),nv);
            gridded=setfield(gridded,[char(opt.vars(v)) '_v'],nvv);
          end        
          count = count + 1;
        end
      end
    else
      gridded.time(count,1) = nanmean(data.time(in));
      gridded.z(count,1) = 1;
      gridded.lon(count,1) = nanmean(x(in));
      gridded.lat(count,1) = nanmean(y(in));
      gridded.num(count,1) = length(in);
      for v=1:length(opt.vars)
        fld=getfield(data,char(opt.vars(v)),{in});
        nv=getfield(gridded,char(opt.vars(v)));
        nvv=getfield(gridded,[char(opt.vars(v)) '_v']);
        nv(count,1) = nanmean(fld(:));
        nvv(count,1) = nanvar(fld(:));
        gridded=setfield(gridded,char(opt.vars(v)),nv);
        gridded=setfield(gridded,[char(opt.vars(v)) '_v'],nvv);
      end        
      count = count + 1;
    end
  end
end

% Matlab has an error in the precision of mean so eliminate beyond 1000th of a day
gridded.time=round(gridded.time*1000)/1000;

% Sort the data in time
[x,m]=sort(gridded.time);
gridded = delstruct(gridded,m);
