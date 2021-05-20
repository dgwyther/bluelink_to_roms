function utildirs = addutils(varargin);
%ADDUTILS Add utility directories to Matlab's search path.
%
%   ADDUTILS adds the utility directories to Matlab's search path.  By
%   default, the directories are appended to the search path.  Any input
%   arguments will be passed to ADDPATH so, for instance, ADDUTILS('-BEGIN')
%   will prepend the directories rather than append them.
%
%   DIRS = ADDUTILS will return the list of directories.  In this case the
%   directories are not added to the path.
%
%   This program might be run in several ways.  One ways is to use
%
%      run /path/to/this/file/addutils
%
%   Another way is to use the following, which allows input arguments to be
%   passed to ADDUTILS,
%
%      cwd = cd;
%      cd /path/to/this/file
%      addutils;
%      cd(cwd);

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:52:29 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % default is to append directories
   if ~nargin
      varargin = {'-end'};
   end

   % get location of this mfile
   [path, name, ext] = fileparts(which([mfilename '.m']));

   % get list of files in directory
   files = dir(path);

   % get full path of each utility directory
   dirs  = {};
   for i = 1:length(files)
      if ( files(i).isdir & ~strncmp( files(i).name, '.', 1 ) & ~strncmp( files(i).name, '@', 1) )
        % Look to see if that directory has an addpath
        ndir = dir([path '/' files(i).name]);
        for k=1:length(ndir),
          if ( strncmp( ndir(k).name, 'addutils', 8 ) )
            eval(sprintf('run %s/%s/addutils',path,files(i).name));
          end
        end
        dirs{end+1} = fullfile(path, files(i).name);
      end
   end

   if nargout
      % return list of directories
      utildirs = dirs;
   else
      % append directories to Matlab's search path
      %addpath(dirs{:}, varargin{:});
      addpath(dirs{:});
   end
