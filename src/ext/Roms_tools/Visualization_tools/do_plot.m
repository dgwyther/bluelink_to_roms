function do_plot(lon,lat,var,maxvar,minvar,...
                 pltstyle,colmin,colmax,ncol,...
		 isobath,hisfile,gridfile,tindex,...
                 vlevel,cstep,rempts,cscale)
%
% Do the plot
%
if maxvar>minvar
  if pltstyle==1
    m_pcolor(lon,lat,var);
    ncol=128;
    shading flat
    colormap(jet)
    caxis([colmin colmax])
  elseif pltstyle==2
    m_contourf(lon,lat,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax]);
%    shading flat
    colormap(jet)
    caxis([colmin colmax])
  elseif pltstyle==3
    [C,h1]=m_contour(lon,lat,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax],'k');
    if ~isempty(h1)
      clabel(C,h1,'LabelSpacing',1000,'Rotation',0)
    end
  elseif pltstyle==4 %gray plot
   dcol=(colmax-colmin)/ncol;
   if minvar <0 
     [C11,h11]=m_contourf(lon,lat,var,[minvar 0]);
      caxis([minvar 0]);
   end
   if colmin < 0
     if minvar < 0 
       hold on
     end
     val=[colmin:dcol:min([colmax -dcol])];
     if length(val)<2
       val=[colmin colmin];
     end  
     [C12,h12]=m_contour(lon,lat,var,val,'k');
     if ~isempty(h12)
       clabel(C12,h12,'LabelSpacing',1000,'Rotation',0)
       set(h12,'LineStyle',':')
     end
     hold off
   end
   if colmax > 0
     if colmin < 0 | minvar < 0
       hold on
     end
     val=[max([dcol colmin]):dcol:colmax];
     if length(val)<2
       val=[colmax colmax];
     end  
     [C13,h13]=m_contour(lon,lat,var,val,'k');
     if ~isempty(h13)
       clabel(C13,h13,'LabelSpacing',1000,'Rotation',0)
     end
     hold off
   end
   hold on
   [C10,h10]=m_contour(lon,lat,var,[0 0],'k');
   if ~isempty(h10)
     clabel(C10,h10,'LabelSpacing',1000,'Rotation',0)
     set(h10,'LineWidth',1.2)
   end
   hold off
   map=0.9+zeros(64,3);
   map2=1+zeros(32,3);
   map(33:64,:)=map2;
   colormap(map)
  elseif pltstyle==5 % Seawifs type plot
    var(var<0.01)=0.01;
    var=(log10(var)+2)/0.015;
    m_pcolor(lon,lat,var);
    shading flat
    caxis([0 256])
    load seawifs.dat
    colormap(seawifs);
  end
end
%
% Add some isobaths
%
if ~isempty(isobath)
  hold on
  eval(['[C2,h2]=draw_topo(gridfile,rempts,['...
  isobath,'],''k--'');']);
  set(h2,'LineWidth',1.5)
  hold off
end
%
% Add the current vectors
%
if cstep~=0;
  hold on
  h3=add_speed_vec(hisfile,gridfile,tindex,...
                   vlevel,cstep,...
		   rempts,cscale);
  set(h3,'Color','k')
  hold off
end
%
% End
%
return
