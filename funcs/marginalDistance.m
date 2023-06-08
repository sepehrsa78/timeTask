function [isWithinLine, distance2cent, numerator] = marginalDistance(pointCent, point, line, radius, dists)

numerator     = (line(1, 2) - line(1, 1)) * (line(2, 1) - point(2)) - (line(1, 1) - point(1)) * (line(2, 2) - line(2, 1));
denominator   = sqrt((line(2, 1) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
distance      = abs(numerator / denominator);
marginPix     = ang2pix(radius, dists.angParams(1), dists.angParams(2));
distance2cent = sqrt((point(1) - pointCent(1)) ^ 2 + (point(2) - pointCent(2)) ^ 2);

dP = point(1) - pointCent(1);
dL = line(1, 1) - pointCent(1);

if distance < marginPix && dL * dP > 0
    isWithinLine = true;
else
    isWithinLine = false;
end

end