function [X, Y] = pointOnLine(line, distanceDeg, taskSettings)

distance      = sqrt((line(1, 2) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
fixRad        = ang2pix(taskSettings.diams.fix / 2, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
tarRad        = ang2pix(taskSettings.diams.set / 2, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
distancePixel = ang2pix(distanceDeg, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));

X = line(1, 2) - (line(1, 2) - line(1, 1)) * ((distancePixel + tarRad + fixRad)/ distance);
Y = line(2, 2) - (line(2, 2) - line(2, 1)) * ((distancePixel + tarRad + fixRad) / distance);

end




