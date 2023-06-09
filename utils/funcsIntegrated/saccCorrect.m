function [dist2centCorrected, pointCorrectedX, pointCorrectedY] = saccCorrect(point, line, distance)

D                  = sqrt((point(:, 1) - line(1, 2)) .^ 2 + (point(:, 2) - line(2, 2)) .^ 2);
alpha              = acos(distance ./ D);
dist2centCorrected = sin(alpha) .* D;

lineDist        = sqrt((line(1, 2) - line(1, 1)) ^ 2 + (line(2, 2) - line(2, 1)) ^ 2);
pointCorrectedX = line(1, 2) - (line(1, 2) - line(1, 1)) * (dist2centCorrected / lineDist);
pointCorrectedY = line(2, 2) - (line(2, 2) - line(2, 1)) * (dist2centCorrected / lineDist);

end