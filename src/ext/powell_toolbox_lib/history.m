function history()

% history
% This function will display your matlab command history

vers = version;
[s,f] = regexp(vers,'\((R[0-9]+)\)');
eval(sprintf('type ~/.matlab/%s/history.m', vers(s+1:f-1)));
