function pxl = ang2pix(ang, d, pxlSize)

if nargin < 3
    pxlSize = 53.5 / 1920;
end

sz = d * 2 * tan(pi * ang / (2 * 180));
pxl = round(sz / pxlSize);

end