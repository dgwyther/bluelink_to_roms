function [t] = tpjason_time(cycle)

% This function, given a TOPEX or Jason time in seconds
% returns the matlab datetime

t = 727564 + cycle./86400;
