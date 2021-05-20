function add_towns(fname,fsize,lonmin,lonmax,latmin,latmax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pierrick 2002
%
% function add_towns(fname,fsize,lonmin,lonmax,latmin,latmax)
%
% add the names of some capes on the image
%
% input:
%
%  fname     town ASCII file name - format: -124.40   42.80  C.+Blanco
%                                          (+ is for a white space)
%                                          last line: 9999 9999 END
%  fsize     font size (scalar) 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=0;
fid = fopen(fname);
while a~=9999
  a = fscanf(fid,'%g',[1]);
  b = fscanf(fid,'%g',[1]);
  c = fscanf(fid,'%s',[1]);
  if (a>lonmin & a<lonmax & b>latmin & b<latmax)
    c(c=='+')=' ';
    m_text(a,b,c,'FontSize',fsize);
  end
end
fclose(fid);
