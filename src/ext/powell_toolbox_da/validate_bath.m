function rec = validate_bath( rec, bath )

% VALIDATE_BATH   Confirm that observations don't go below the bottom depth
%
% Given an observation record, check the grid bathymetry to make sure that
% we don't assimilate obs below the grid depth
% 
% SYNTAX
%   REC = VALIDATE_BATH( REC, BATH )
% 

if ( nargin < 2 )
  error('You must specify a record and bathymetry');
end

% Only check depths below 0
ind = sub2ind(size(bath), floor(rec.y)+1, floor(rec.x)+1);
l = find( ~isnan(ind) );
h = bath( rmnan( sub2ind(size(bath), floor(rec.y(l))+1, floor(rec.x(l))+1) ));
m = l(find( rec.z(l) < -h ));
% Delete the records below the grid depth
l = [1:length(rec.z)]';
l(m)=[];
rec = delstruct(rec, l, length(rec.z));

  
