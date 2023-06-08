function [X, Y] = pointOnLine(line, distanceDeg, dists, diams)

distance      = sqrt((line(1, 2) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
fixRad        = ang2pix(diams.fix / 2, dists.angParams(1), dists.angParams(2));
tarRad        = ang2pix(diams.set / 2, dists.angParams(1), dists.angParams(2));
distancePixel = ang2pix(distanceDeg, dists.angParams(1), dists.angParams(2));

X = line(1, 2) - (line(1, 2) - line(1, 1)) * ((distancePixel + tarRad + fixRad)/ distance);
Y = line(2, 2) - (line(2, 2) - line(2, 1)) * ((distancePixel + tarRad + fixRad) / distance);

end




