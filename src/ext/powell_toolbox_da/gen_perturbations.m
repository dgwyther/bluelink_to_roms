function gen_perturbations( opt, tlm_files )

% GEN_PERTURBATIONS   Generate orthogonal perturbations
%
% For the given list of tlm_files, load all TLM perturbations in the directory
% and orthonormalize them
% 
% SYNTAX
%   GEN_PERTURBATIONS( OPT, TLM_FILES )
% 
% opt is structure holding info:
% opt = 
% 
%                  grid: '/share/frinkraid2/ivica/roms-hiomwg/roms-hiomwg-grid-sg4.nc'
%                  std: '../ncfiles/hiomwg_std_i.nc'
%    tlm_perturbations: 10
%                  day: 1611
%

N = length(tlm_files);

% Load the standard deviations to unit normalize the TL perturbations
rec = floor(mod(opt.day,365)/365.25 * 12)+1;
[tlm_std,ocean,len] = tlm_read(opt.std, opt.grid, rec);
tlm_std(find(isnan(tlm_std)))=eps;

% If there are more than 40 files, then we may run into memory issues
if (length(tlm_files)>40)
  disp('WARNING: Memory may get tight');
end

% Load the vectors
for i=1:N,
  disp(tlm_files(i));
  tmp=tlm_read(char(tlm_files(i)),opt.grid);
  tmp(find(isnan(tmp)))=eps;
  a(:,i) = tmp ./ tlm_std;
end

% Clean out vectors from the first outer loop
m = find( nanmean(a) );
N = length(m);
a = a(:,m);

% Next, use the Modified Gram-Schmidt orthonormalization to 
% our list of TL perturbations
% Go over each file and orthonormalize it
for i=1:N,
  r(i,i) = norm( a(:,i) );
  a(:,i) = a(:,i) / r(i,i);
  r(i,i+1:N) = transpose(a(:,i)) * a(:,i+1:N);
  a(:,i+1:N) = a(:,i+1:N) - a(:,i)*r(i,i+1:N);
end  

% Next, use a random combination of the orthogonal vectors to create
% a list of perturbations based upon the RMS of the misfit from the
% assimilation that generated the TL perturbations
alpha = randn(opt.tlm_perturbations,N);
for i=1:opt.tlm_perturbations,
  file = num2str(i,'pert_%03d.nc');
  unix(['cp ' char(tlm_files(1)) ' ' file]);
  disp(file);

  na = ( a * transpose(alpha(i,:)) ) .* tlm_std;
  na(isnan(na))=0;
  tlm_write(file,na,opt.grid);
end


