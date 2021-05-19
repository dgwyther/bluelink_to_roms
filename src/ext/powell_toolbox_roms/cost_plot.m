function [j, n] = cost_plot( file, do_plot )

if ( nargin == 1 )
  do_plot = true;
end

isVars={ 'total' 'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt' };
j = nc_varget(file, 'cost_function') + nc_varget(file,'back_function');
cg = nc_varget(file, 'cost_gradient');
n = nc_varget(file, 'Nobs');
n(1) = sum(n(2:end));
nobs = n(1);
cols = find(j(1,:));
scale = j(1,cols);
jn = j(:,cols) ./ scale(ones(size(j,1),1),:);
s = ones(size(j))*sqrt(nobs);
if ( ~do_plot ) return; end

set(gcf,'color',[1 1 1]);

subplot(2,2,1);
x=[1:size(j,1)]';
d = 2*j(:,cols)/nobs;
plot( d,'linewidth',2 );
set(gca,'color',[.95 .95 .95]);
grid on;
axis([0 max(x(:)) 0 max(abs(d(:)))]);
hold on
plot(x,1+sqrt(2/nobs),'b:',x,1-sqrt(2/nobs),'b:');
title(file,'Interpreter','none');
legend(isVars(cols));
xlabel('J (# std)');
subplot(2,2,2);
plot(jn,'linewidth',2); grid on
set(gca,'color',[.95 .95 .95]);
axis([1 size(jn,1) 0 max(jn(:))]);
xlabel('J (scaled)')
legend(isVars(cols));
subplot(2,2,3);
plot(j(:,cols),'linewidth',2); grid on
set(gca,'color',[.95 .95 .95]);
axis([1 size(j,1) 0 max(j(:))]);
xlabel('J')
legend(isVars(cols));


cols = find(cg(1,:));
scale = cg(1,cols);
cg = cg(:,cols) ./ scale(ones(size(cg,1),1),:);


subplot(2,2,4);
plot(cg,'linewidth',2); grid on
set(gca,'color',[.95 .95 .95]);
legend(isVars(cols));
xlabel('CG')
