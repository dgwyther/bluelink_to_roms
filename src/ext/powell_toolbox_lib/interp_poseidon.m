DATA_DIR='/projects/stack_alt/data/quan35_gsfc_ssh/';
SUFFIX='.ssh';
load poseidon_cycles;

%poseidon_cycles(size(poseidon_cycles,1)+1) = 118;
%poseidon_cycles(size(poseidon_cycles,1)+1) = 234;
%poseidon_cycles(size(poseidon_cycles,1)+1) = 243;
%poseidon_cycles(size(poseidon_cycles,1)+1) = 289;
%poseidon_cycles(size(poseidon_cycles,1)+1) = 299;
%poseidon_cycles = [ [246]; [256]; ];
poseidon_cycles = [ 361 ];

for i = 1:size(poseidon_cycles),
  cycle = poseidon_cycles(i);
  fprintf(1,'Cycle: %d\n', cycle);

  % Load the previous cycle
  filename=[DATA_DIR sprintf('topex_%03d', cycle-1) SUFFIX];
  fprintf(1,'Loading %s\n', filename);
  fid=fopen(filename, 'r');
  previous_data=fread(fid,inf,'integer*2');
  fclose(fid);

  % Load the next cycle
  filename=[DATA_DIR sprintf('topex_%03d', cycle+1) SUFFIX];
  fprintf(1,'Loading %s\n', filename);
  fid=fopen(filename, 'r');
  next_data=fread(fid,inf,'integer*2');
  fclose(fid);

  % Make sure we don't use bad data
  previous_data(find(previous_data == 32767)) = NaN;
  next_data(find(next_data == 32767)) = NaN;

  % interpolate
  data = (next_data + previous_data) / 2;
  
  % Set the NaN's back to bad flag
  data(find(isnan(data))) = 32767;
  
  % Save out the cycle
  filename=[DATA_DIR sprintf('interp_%03d', cycle) SUFFIX];
  fprintf(1,'Saving %s\n', filename);
  fid=fopen(filename, 'wb');
  fwrite(fid,data,'integer*2');
  fclose(fid);
  
end
