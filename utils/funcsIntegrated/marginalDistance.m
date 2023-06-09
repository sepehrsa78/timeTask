function [isWithinLine, distance2cent, distance] = marginalDistance(taskSettings, point, rects)

v1 = rects.lineOS(:, 1)';
v2 = rects.lineOS(:, 2)';

if length(v1) == 2
    v1(3) = 0;  
end 
if length(v2) == 2
    v2(3) = 0;  
end
if size(point, 2) == 2
    point(1, 3) = 0;
end 

v1T           = repmat(v1, size(point, 1), 1);
v2T           = repmat(v2, size(point, 1), 1);
a             = v1T   - v2T;
b             = point - v2T;
distance      = sqrt(sum(cross(a, b, 2) .^ 2, 2)) ./ sqrt(sum(a .^ 2, 2));
marginPix     = ang2pix(taskSettings.rads.spaceMargin, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
distance2cent = sqrt((point(1) - v2(1)) ^ 2 + (point(2) - v2(2)) ^ 2);

dP = point(1) - v2(1);
dL = rects.lineOS(1, 1) - v2(1);

if distance(1) < marginPix && dL * dP > 0
    isWithinLine = true;
else
    isWithinLine = false;
end

end