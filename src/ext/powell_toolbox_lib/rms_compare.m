DATA_NOM_DIR='/projects/altimetry/slope_data/ssh_nom_slope/';
DATA_RELAX_DIR='/projects/altimetry/slope_data/ssh_relax_slope/';
SRC_DIR='/homes/brpowell/projects/stack/mean_ssh/';
CYCLE_START=12;       % Cycle to start on
CYCLE_END=300;        % Cycle to end on
NLAT=75-(1/60);       % Northern most latitude of box
SLAT=-75+(1/60);       % Southern most latitude of box
WLON=0+(1/60);      % Western most longitude of box
ELON=360-(1/60);      % Eastern most longitude of box

% Load up the data
fprintf(1,'Load Data Sets\n');
load poseidon_cycles;
load along_data.mat

%------------------------------------------------     
% Setup the area we are going to use and grab
% the bathymetry
fprintf(1,'Setup Area and Bathymetry\n');
area=find(along_lon>=WLON & along_lon<=ELON & along_lat>=SLAT & along_lat<=NLAT);
my_bath=along_bath(area);
my_bath(find(my_bath < 130 | my_bath==32767))=NaN;
my_region=along_region(area);

%------------------------------------------------     
% Loop from the start cycle to end cycle

for i = CYCLE_START:CYCLE_END,
  % Load the nominal file & setup lovin
  filename=[DATA_NOM_DIR sprintf('gdr_%03d.slope', i)];
  fid=fopen(filename, 'r');
  nom_data=fread(fid,inf,'integer*2');
  fclose(fid);
  
  % Load the relaxed file & setup lovin
  filename=[DATA_RELAX_DIR sprintf('gdr_%03d.slope', i)];
  fid=fopen(filename, 'r');
  relax_data=fread(fid,inf,'integer*2');
  fclose(fid);

  % Grab the area we want
  nom_data=nom_data(area);
  relax_data=relax_data(area);

  % Filter out bad data, land, etc.
  nom_data(find(nom_data==32767))=NaN;
  relax_data(find(abs(relax_data)>3000))=NaN;
  nom_data(find(my_region==2))=NaN;
  relax_data(find(my_region==2))=NaN;
  nom_data(find(isnan(my_bath)))=NaN;
  relax_data(find(isnan(my_bath)))=NaN;

  % De-mean the data
%  nom_data = nom_data - mean(nom_data);
%  relax_data = relax_data - mean(relax_data);
  
  % Compute the RMS
  nom_rms = nanstd(nom_data);
  relax_rms = nanstd(relax_data);

  % Output the results
  fprintf(1,'%03d\t%6.3f\t%6.3f\n',i,nom_rms,relax_rms);
  
  % Store the cycle and mean in our database
  output_data(size(output_data,1)+1,:) = [i nom_rms relax_rms];
end

% Demean the RMS
output_data(2,:) = output_data(2,:) - mean(output_data(2,:));
output_data(3,:) = output_data(3,:) - mean(output_data(3,:));

% Plot the final results
figure(101);
plot(output_data(:,1), output_data(:,2));
hold on
plot(output_data(:,1), output_data(:,3), 'r');
xlabel('Cycle');
ylabel('RMS (mm)');
title('RMS vs. Cycle');
hold off
