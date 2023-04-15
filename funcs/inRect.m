function inside = inRect(x, y, rect)

if (x >= rect(RectLeft) && x <= rect(RectRight) && ...
		y >= rect(RectTop) && y <= rect(RectBottom))
	inside = true;
else
	inside = false;
end
