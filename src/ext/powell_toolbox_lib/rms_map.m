DIR = '/projects/stack_alt/data/nom_jpl_slope/';
start = 11;
finish = 350;
suffix = 'slope';

progress;

% Load the mean
progress(finish-start+2,1);
fid=fopen([DIR 'trim_mean.' suffix],'r');
means=fread(fid,inf,'integer*2');
fclose(fid);
length=size(means,1);

% Create the info
rmsmap = zeros(length,1);
counts = zeros(length,1);

% Process each cycle
for i=start:finish,
  progress(finish-start+2,i-start+2);
  % Load the file
  file=sprintf('gdr_%03d.%s',i,suffix);
  fid=fopen([DIR file],'r');
  data=fread(fid,inf,'integer*2');
  fclose(fid);

  % Find the good data
  good = find( abs(data) < 400 & abs(means) < 400 );

  % Calculate RMS, add counts
  rmsmap(good) = rmsmap(good) + (data(good) - means(good)).^2;
  counts(good) = counts(good) + 1;
end

% Finish results
  progress(finish-start+2,finish-start+2);
good=find( counts > 0 );
rmsmap(good) = sqrt(rmsmap(good) ./ counts(good));
clear good;
