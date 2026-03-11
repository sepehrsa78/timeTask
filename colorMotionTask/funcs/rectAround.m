
function rect = rectAround(rect_center, rect_size)

% function rect = rectAround(rect_center, rect_size)
% 
% defines a rect of size rect_size centered on rect_center
% 
% Input 
%   rect_center     [center_x, center_y]
%   rect_size       [width, height]
% Output
%   rect            [xmin, ymin, xmax, ymax]
% 

% 
% 09/29/07  Developed by RK
% 

rect = [rect_center(:,1)-rect_size(:,1)/2, rect_center(:,2)-rect_size(:,2)/2, ...
        rect_center(:,1)+rect_size(:,1)/2, rect_center(:,2)+rect_size(:,2)/2];

