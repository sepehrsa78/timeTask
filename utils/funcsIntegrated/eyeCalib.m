function el = eyeCalib(window, width, height, backColor)

% STEP 4: SET CALIBRATION SCREEN COLOURS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE

% Provide EyeLink with some defaults, which are returned in the structure "el".
el = EyelinkInitDefaults(window);
% set calibration/validation/drift-check(or drift-correct) size as well as background and target colors.
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
% pupil size changes (which can cause a drift in the eye movement data)
% el.calibrationtargetsize = 3;% Outer target size as percentage of the screen
% el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
el.backgroundcolour = backColor; 
% RGB grey
% el.calibrationtargetcolour = [255 255 255];% RGB White
% % set "Camera Setup" instructions text colour so it is different from background colour
% el.msgfontcolour = [255 255 255];% RGB White
% You must call this function to apply the changes made to the el structure above
EyelinkUpdateDefaults(el);

% Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width - 1, height - 1);
% Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
% See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width - 1, height - 1);
% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV9'); % horizontal-vertical 9-points
% Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
Eyelink('Command', 'button_function 5 "accept_target_fixation"');

% Start listening for keyboard input. Suppress keypresses to Matlab windows.
% ListenChar(-1);
Eyelink('Command', 'clear_screen 0'); % Clear *Host PC* display from any previus drawing

% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
% do a final check of calibration using driftcorrection
EyelinkDoTrackerSetup(el);
EyelinkDoDriftCorrection(el);
% Check which eye is available for gaze-contingent drawing. Returns 0 (left), 1 (right) or 2 (binocular)
eye_used = Eyelink('EyeAvailable');
% Get samples from left eye if binocular
if eye_used == 2
    eye_used = 0;
end


end