function [isWithinLine, distance2cent] = marginalDistance(pointCent, point, line, radius, dists)

numerator     = abs((line(1, 2) - line(1, 1)) * (line(2, 1) - point(2)) - (line(1, 1) - point(1)) * (line(2, 2) - line(2, 1)));
denominator   = sqrt((line(2, 1) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
distance      = numerator / denominator;
marginPix     = ang2pix(radius, dists.angParams(1), dists.angParams(2));
distance2cent = sqrt((point(1) - pointCent(1)) ^ 2 + (point(2) - pointCent(2)) ^ 2);

if point(2) <= pointCent(2) && distance < marginPix
    isWithinLine = true;
else
    isWithinLine = false;
end

end