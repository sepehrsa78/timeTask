function deg = pix2ang(pxl, d, pxlSize)

if nargin < 3
    pxlSize = 53.5 / 1920;
end

deg = round(2 * (180 / pi) * atan((pxlSize * pxl) / (d * 2)));

end