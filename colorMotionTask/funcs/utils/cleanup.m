function cleanup
Screen('CloseAll'); % Close window if it is open
Eyelink('Shutdown'); % Close EyeLink connection
ListenChar(0); % Restore keyboard output to Matlab
ShowCursor; % Restore mouse cursor
end