function mod_write( filename, model )

% mod_write( filename, model )
%
% Given a record of nlmodel_value, nlmodel_initial, and tlmodel_value,
% create a modfile
%
% Created by Brian Powell on 2008-3-5
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<2)
  error('you must specify a filename and model struct');
end

vars = {'nlmodel_initial' 'nlmodel_value' 'tlmodel_value' };

has = find(isfield(model, vars));
if (isempty(has))
  error('You must specify a record in mod struct');
end

% Get the minimum value
datum=inf;
for v=1:length(has),
  datum = min([datum length(getfield(model,char(vars(has(v)))))]);
end

% Fill everything out
for v=1:length(vars)
  if (isempty(find(has==v)))
    model = setfield(model,char(vars(v)),zeros(datum,1));
  else
    data = getfield(model,char(vars(v)));
    data = reshape(data(1:datum),datum,1);
    model = setfield(model,char(vars(v)),data);
  end
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'MOD File' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
nc_attput( filename, nc_global, 'author', user.name );
nc_attput( filename, nc_global, 'date', datestr(now));
nc_attput( filename, nc_global, 'type', 'ROMS Model File');
nc_attput( filename, nc_global, 'Conventions', 'CF-1.0');

% Add the dimensions
nc_add_dimension( filename, 'record', 1 );
nc_add_dimension( filename, 'state_var', 8 );
nc_add_dimension( filename, 'datum', datum );

% Add the variables
rec = [];
rec.Name = 'NLmodel_initial';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'initial nonlinear model at observation locations';
rec.Attribute(2).Name = '_FillValue';
rec.Attribute(2).Value = 1e-6;
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, model.nlmodel_initial );

rec = [];
rec.Name = 'NLmodel_value';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'nonlinear model at observation locations';
rec.Attribute(2).Name = '_FillValue';
rec.Attribute(2).Value = 1e-6;
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, model.nlmodel_value );

rec = [];
rec.Name = 'TLmodel_value';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'tangent linear model at observation locations';
rec.Attribute(2).Name = '_FillValue';
rec.Attribute(2).Value = 1e-6;
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, model.tlmodel_value );

rec = [];
rec.Name = 'obs_scale';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'observation screening/normalization scale';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, ones(datum,1) );
