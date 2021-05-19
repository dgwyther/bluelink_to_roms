function rec = coads_read_hdat(file)


[header,hinfo,htype,hdata]=rhydro(file);

% Unpack data.

[nhvar,nhpts,nhsta]=size(hdata);

lon=hinfo(:,4);
lat=hinfo(:,5);

time   = squeeze(hdata(1,:,:));
hflux  = squeeze(hdata(2,:,:));
swrad  = squeeze(hdata(3,:,:));
fwflux = squeeze(hdata(4,:,:));
sst    = squeeze(hdata(5,:,:));
dqdsst = squeeze(hdata(6,:,:));
sustr  = squeeze(hdata(7,:,:));
svstr  = squeeze(hdata(8,:,:));

%  Rearrange data into matrices.

LonMin=min(lon);
LonMax=max(lon);
x=LonMin:1:LonMax;
Im=length(x);

I=zeros(size(lon));
for i=1:Im,
  ind=find(lon == x(i));
  I(ind)=i;
end,

LatMin=min(lat);
LatMax=max(lat);
y=LatMin:1:LatMax;
Jm=length(y);

J=zeros(size(lat));
for j=1:Jm,
  ind=find(lat == y(j));
  J(ind)=j;
end,

TimeMin=min(min(time));
TimeMax=max(max(time));
t=TimeMin:30:TimeMax;
Km=length(t);

rec.lon=repmat(x',[1 Jm]);
rec.lat=repmat(y,[Im 1]);

rec.hflux =ones([Im Jm Km]).*NaN;
rec.swrad =ones([Im Jm Km]).*NaN;
rec.wflux =ones([Im Jm Km]).*NaN;
rec.sst   =ones([Im Jm Km]).*NaN;
rec.dqdsst=ones([Im Jm Km]).*NaN;
rec.sustr =ones([Im Jm Km]).*NaN;
rec.svstr =ones([Im Jm Km]).*NaN;

for k=1:nhpts,
  for n=1:nhsta,
    i=I(n);
    j=J(n);
    rec.hflux(i,j,k) =hflux(k,n);
    rec.swrad(i,j,k) =swrad(k,n);
    rec.wflux(i,j,k) =fwflux(k,n);
    rec.sst(i,j,k)   =sst(k,n);
    rec.dqdsst(i,j,k)=dqdsst(k,n);
    rec.sustr(i,j,k) =sustr(k,n);
    rec.svstr(i,j,k) =svstr(k,n);
  end,
end,

rec.hmask=ones(size(rec.lon));
ind=find(isnan(squeeze(rec.hflux(:,:,1))));
rec.hmask(ind)=0;

rec.vmask=ones(size(rec.lon));
ind=find(isnan(squeeze(rec.sustr(:,:,1))));
rec.vmask(ind)=0;


rec.lon    = permute(rec.lon,[2 1]);
rec.lon    = rec.lon(1,:)';
rec.lat    = permute(rec.lat,[2 1]);
rec.lat    = rec.lat(:,1);
rec.hmask  = permute(rec.hmask,[2 1]);
rec.vmask  = permute(rec.vmask,[2 1]);

rec.hflux  = permute(rec.hflux,[3 2 1]);
rec.swrad  = permute(rec.swrad,[3 2 1]);
rec.wflux  = permute(rec.wflux,[3 2 1]);
rec.sst    = permute(rec.sst,[3 2 1]);
rec.dqdsst = permute(rec.dqdsst,[3 2 1]);
rec.sustr  = permute(rec.sustr,[3 2 1]);
rec.svstr  = permute(rec.svstr,[3 2 1]);
