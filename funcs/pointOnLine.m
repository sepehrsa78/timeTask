function [X, Y] = pointOnLine(line, distanceDeg, dists)

distance      = sqrt((line(1, 2) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
distancePixel = ang2pix(distanceDeg, dists.angParams(1), dists.angParams(2));

X = line(1, 2) - (line(1, 2) - line(1, 1)) * (distancePixel / distance);
Y = line(2, 2) - (line(2, 2) - line(2, 1)) * (distancePixel / distance);

end




