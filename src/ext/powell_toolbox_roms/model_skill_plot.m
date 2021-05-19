function h = model_skill_plot( std_ref, std_model, cc, style )

if ( nargin < 4 )
  style = 'b+-';
end

mmpolar(acos(cc),std_model,style,acos(cc(1)),std_model(1),'ks',zeros(length(std_ref),1),std_ref,'kd','tlimit',[0 pi]);
ticks = [ .2 .4 .6 .8 .9 .975 1 ];
ticks = [ fliplr(ticks) -ticks ];
mmpolar('ttickvalue',rad2deg(acos(ticks)));
mmpolar('tticklabel',cellstr(num2str(ticks')));

