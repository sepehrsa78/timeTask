function isHit = targetHit(target, point, marginDeg, dists)

distance  = sqrt((point(1) - target(1)) ^ 2 + (point(2) - target(2)) ^ 2);
marginPix = ang2pix(marginDeg, dists.angParams(1), dists.angParams(2));

if distance < marginPix
    isHit = true;
else
    isHit = false;
end





