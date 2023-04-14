function isWithinLine = marginalDistance(point, line, radius, dists)


numerator   = abs((line(1, 2) - line(1, 1)) * (line(2, 1) - point(2)) - (line(1, 1) - point(1)) * (line(2, 2) - line(2, 1)));
denominator = sqrt((line(2, 1) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
distance    = numerator / denominator;
marginPix   = ang2pix(radius, dists.angParams(1), dists.angParams(2));

if distance < marginPix
    isWithinLine = true;
else
    isWithinLine = false;
end

end