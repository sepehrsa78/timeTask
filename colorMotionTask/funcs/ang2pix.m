function pxl = ang2pix(ang, d, pxlSize)

if nargin < 3
    pxlSize = 53.5 / 1920;
end

pxl = round(d * 2 * tan(pi * ang / (2 * 180)) / pxlSize);

end

