function files = ls_files(dirname, ext, lt)

%
% files = ls_files(dirname, ext, lt)
%
% Grab the list of files from a directory with the given file extension
% and sort by date if lt is true; otherwise, sort by name

if ( nargin < 3 )
  lt = false;
end
if ( nargin < 2 )
  ext = 'nc';
end
files = {};
dat = dir(dirname);
if ( isempty(dat) ) return; end
if ( lt )
  for i=1:length(dat),
    t(i) = datenum(dat(i).date);
  end
  [t,l] = sort(t,2,'descend');
  dat = dat(l);
end
count = 1;
for i=1:length(dat),
  if ( ~dat(i).isdir & regexp(dat(i).name,[ext '$']) )
    files(count) = cellstr([dirname '/' dat(i).name]);
    count = count + 1;
  end
end
if ( ~lt )
  files = sort(files);
end
