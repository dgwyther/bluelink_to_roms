function res = calc_stats(model, obs, ref, err)

% res = calc_stats(model, obs, ref, [err])
%
% This function provides base statistics comparing the model
% to a set of observations.
%

if ( nargin<2 )
  error('you must specify model and obs');
end
if ( nargin<4 )
  err=zeros(size(model));
end

n=numel(model);
if ( n ~= numel(obs) )
  error('model and obs must be same size');
end

model=reshape(model,n,1);
obs=reshape(obs,n,1);
ref=reshape(ref,n,1);

good=find( ~isnan(model) & ~isnan(obs) );
if ( isempty(good) ) 
 res=ones(1,11)*nan; 
 return
end
model=model(good);
obs=obs(good);
ref=ref(good);
err=err(good);

%model(find(~model))=nan;
%ref(find(~ref))=nan;
stdm = nanstd( model ) + eps;
stdo = nanstd( obs ) + eps;

% Calculate the results
l=find(err);
if (isempty(l)) 
  Jo = 0;
else
  Jo = 0.5 * nansum( ((model(l)-obs(l)).^2) ./ err(l) );
end
mse = nanmean( (model - obs).^2 );
msef = nanmean( (ref - obs).^2 );
mb = nanmean( model ) - nanmean( obs );
sde = stdm - stdo;
cc = nanmean( (model - nanmean(model)).*(obs - nanmean(obs)) ) / ...
      ( stdm * stdo );
if ( nargin > 2 )
  ss = 1 - mse/(msef+eps);
else
  ss = 1;
end
del = mse - (mb^2 + sde^2 + 2*nanstd(model)*nanstd(obs)*(1-cc));
res = [ mse mb sde cc ss 2*nanstd(model)*nanstd(obs)*(1-cc) del ...
        nanstd(model) nanstd(obs) Jo length(obs) ];
