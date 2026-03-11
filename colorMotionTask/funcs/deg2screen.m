function s = deg2screen (d, screen_struct, format)

% function s = deg2screen (d, screen_struct, format)
% 
% returns the location of d in screen coordinate. d can be a vector or a
% matrix with two rows or columns. the format is defined by 'format' which
% can take 'vector' ('v'), 'column matrix' ('cm'), or 'row matrix' ('rm').
% in the vector format the data in each row is assumed to be in [x y x y ...] 
% form (for example a rect: [xmin ymin xmax ymax]). in the matrix format
% each row (column) is assumed to be an [x y] pair.
% 
% the function assumes that degree coordinate is centered on the screen
% center. for example [-10 0] mean 10 degree to the left of the screen
% center. 
% 
% Input
%   d
%   screen_struct
%   format
% 
% Output
%   s       location in screen coordinate
% 
% 

% 
% 09/26/07  Developed by RK
% 

s = zeros(size(d));

if nargin < 3 || isempty(format),
    [m, n] = size(d);
    if m==1 || n==1,
        format = 'v';
    elseif n == 2,
        format = 'cm';
    elseif m == 2,
        format = 'rm';
    end;
end;

switch format
    %if d is a vector, for example a rect, assume an [x y x y ...]
    %arrangement 
    case {'v','vector'},
        s(:,1:2:end) = mean(screen_struct.screen_rect([1 3])) + d(:,1:2:end) * screen_struct.pix_per_deg;
        s(:,2:2:end) = mean(screen_struct.screen_rect([2 4])) - d(:,2:2:end) * screen_struct.pix_per_deg;
    %otherwise assume the first column (row) is x and the second column
    %(row) is y
    case {'cm','column matrix'},
        s(:,1) = mean(screen_struct.screen_rect([1 3])) + d(:,1) * screen_struct.pix_per_deg;
        s(:,2) = mean(screen_struct.screen_rect([2 4])) - d(:,2) * screen_struct.pix_per_deg;
    case {'rm','row matrix'},
        s(1,:) = mean(screen_struct.screen_rect([1 3])) + d(1,:) * screen_struct.pix_per_deg;
        s(2,:) = mean(screen_struct.screen_rect([2 4])) - d(2,:) * screen_struct.pix_per_deg;
    otherwise,
        error('Deg2Screen:UnknownFormat', 'Input of deg2screen should be either a vector or a 2*n or n*2 matrix');
end;
