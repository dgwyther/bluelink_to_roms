function e = axes2ecc(smajor, sminor)

% e = axes2ecc(smajor, sminor)
% This function clones the map toolbox, converting semimajor
% and semiminor axes of an ellipse into eccentricity
if ( nargin ~= 2 )
  error('Incorrect input');
end
e = sqrt(real(smajor).^2 - real(sminor).^2) ./ smajor;
