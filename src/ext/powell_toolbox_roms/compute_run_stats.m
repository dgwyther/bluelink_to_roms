function [avg, sdev]=compute_run_stats(avg_files,his_files,nrecs,epoch,vars,dims)

%   COMPUTE_RUN_STATS   Generate average and standard deviations
%     [avg, sdev] = compute_run_stats(avg_files, his_files, nrecs)
% 
%   Given records of average and history files, generate the
%   average and standard deviations. nrecs determines the period
%   (e.g., 4 for seasonal, 12 for monthly, 1 for annual), epoch
%   is the model-run epoch.
%   

% Which variables to compute
if nargin<5
  vars = {'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt' 'ssflux' 'shflux' ...
          'sustr' 'svstr'};
  dims = [3 3 3 4 4 4 4 3 3 3 3];
end

good=[];
for v=1:length(vars),
  if nc_isvar(char(avg_files(1)),char(vars(v))),
    good=[good; v];
    s=ones(1,dims(v))*-1; s(1)=1;
    s=size(nc_varget(char(avg_files(1)),char(vars(v)),s*0,s));
    s(1)=nrecs;
    evalc(['avg.' char(vars(v)) '=zeros(s);']);
    evalc(['sdev.' char(vars(v)) '=zeros(s);']);
  end
end
vars=vars(good);
% First, create a running average
count=zeros(nrecs,1);
idx=0;
progress(0,0,1);
tot=length(avg_files)*length(vars)*nrecs+length(his_files)*length(vars)*nrecs+nrecs*length(vars);
for f=1:length(avg_files),
  file=char(avg_files(f));
  t=nc_varget(file,'ocean_time')/86400 + epoch;
  [ssn,mon]=season(t);
  for n=1:nrecs,
    if nrecs==4,
      l=find(ssn==n);
    elseif nrecs==12,
      l=find(mon==n);
    else
      l=[1:length(t)];
    end
    if isempty(l), continue; end
    count(n)=count(n)+length(l);
    for v=1:length(vars),
      vr=char(vars(v));
      idx=idx+1;
      progress(tot,idx,1);
      % The data may be discontinuous, so we have to load it carefully
      data=[];
      nl=l;
      while ( length(nl)>0 )
        d=diff(nl);
        mx=max(d);
        if ( isempty(mx) | mx==1 )
          m=nl;
          nl=[];
        else
          m=[1:find(d>1)];
          nl=nl(m(end)+1:end);
        end
        if (dims(v)==3)
          data=[data; nc_varget(file,vr,[m(1)-1 0 0],[length(m) -1 -1])];
        else
          data=[data; nc_varget(file,vr,[m(1)-1 0 0 0],[length(m) -1 -1 -1])];
        end
      end
      evalc(['avg.' vr '(n,:)=' 'avg.' vr '(n,:)+sum(data(:,:),1);']);
    end
  end
end
for v=1:length(vars),
  for n=1:nrecs,
    evalc(['avg.' char(vars(v)) '(n,:)=' 'avg.' char(vars(v)) '(n,:)/count(n);']);
  end
end

% Next, create the std
count=zeros(nrecs,1);
for f=1:length(his_files),
  file=char(his_files(f));
  t=nc_varget(file,'ocean_time')/86400 + epoch;
  [ssn,mon]=season(t);
  for n=1:nrecs,
    if nrecs==4,
      l=find(ssn==n);
    elseif nrecs==12,
      l=find(mon==n);
    else
      l=[1:length(t)];
    end
    if isempty(l), continue; end
    count(n)=count(n)+length(l);
    for v=1:length(vars),
      vr=char(vars(v));
      idx=idx+1;
      progress(tot,idx,1);
      % The data may be discontinuous, so we have to load it carefully
      data=[];
      nl=l;
      while ( length(nl)>0 )
        d=diff(nl);
        mx=max(d);
        if ( isempty(mx) | mx==1 )
          m=nl;
          nl=[];
        else
          m=[1:find(d>1)];
          nl=nl(m(end)+1:end);
        end
        if (dims(v)==3)
          data=[data; nc_varget(file,vr,[m(1)-1 0 0],[length(m) -1 -1])];
        else
          data=[data; nc_varget(file,vr,[m(1)-1 0 0 0],[length(m) -1 -1 -1])];
        end
      end
      % Now that we have all of the data, compute a running squared difference
      nl=size(data,1);
keyboard
      if (dims(v)==3)
        evalc(['sdev.' vr '(n,:,:)=sdev.' vr '(n,:,:)+sum((data-repmat(avg.' vr '(n,:,:), [nl 1 1])).^2,1)']);
      else
        evalc(['sdev.' vr '(n,:,:,:)=sdev.' vr '(n,:,:,:)+sum((data-repmat(avg.' vr '(n,:,:,:), [nl 1 1 1])).^2,1)']);
      end
    end
  end
end
for v=1:length(vars),
  for n=1:nrecs,
    idx=idx+1;
    progress(tot,idx,1);
    evalc(['sdev.' char(vars(v)) '(n,:)=' 'sqrt(sdev.' char(vars(v)) '(n,:)/(count(n)-1));']);
  end
end
