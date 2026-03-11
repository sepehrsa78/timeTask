# Color-Motion Discrimination Task

A saccade-based psychophysics task where subjects integrate **motion direction** and **dot color** to make left/right decisions. Built on PsychToolbox and EyeLink, using a state machine architecture for flexible pause/resume control.

## Task Design

Random dots move coherently (up or down) and are colored (green or red). The subject must integrate both dimensions and saccade to the correct target using an **XOR mapping rule**:

| Motion | Color | Correct Target |
|--------|-------|----------------|
| Up     | Green | RIGHT          |
| Down   | Red   | RIGHT          |
| Down   | Green | LEFT           |
| Up     | Red   | LEFT           |

**Same-sign = RIGHT, different-sign = LEFT.**

Both motion coherence and color coherence are parametrically varied, creating a 2D psychometric space.

## Requirements

- MATLAB (R2020a or later recommended)
- [Psychtoolbox-3](http://psychtoolbox.org/)
- [EyeLink Developers Kit](https://www.sr-research.com/support/forum-9.html) (SR Research)
- EyeLink eye tracker connected and configured

## Quick Start

1. Navigate to the `colorMotionTask/` directory in MATLAB
2. Run `colorMotionTask`
3. Follow the dialog prompts:
   - First session: enter subject info (name, number, age, gender, hand, demo mode)
   - Returning session: select subject from list to resume
4. Complete EyeLink calibration
5. Press any key to start trials

**Demo mode**: Enter `1` in the Demo field to run a short session with 1 repetition per condition.

## State Machine

The task runs as a central dispatcher looping over states:

```
TRIAL_SETUP --> FIXATION --> DOTS --> FEEDBACK --> ITI --> TRIAL_SETUP ...
                                                              |
                (ESCAPE pressed)                              v
                     |                                   (all done?)
                     v                                        |
                   PAUSE -----> RESUME --> TRIAL_SETUP        v
                     |                                   SET_COMPLETE
                     +--> RECALIBRATE --> TRIAL_SETUP         |
                     |                                   Y: new set
                     +--> SAVE & QUIT --> FINISH         N: FINISH
```

### State Descriptions

| State | Behavior |
|-------|----------|
| **TRIAL_SETUP** | Pre-generate dots, compute screen geometry for current trial |
| **FIXATION** | Gaze-gated: waits until participant fixates for 100ms before advancing |
| **DOTS** | Display dots + targets, poll EyeLink each frame for saccade |
| **FEEDBACK** | Green (correct) or yellow (error) visual feedback |
| **ITI** | Blank screen, auto-save trial data, check for ESCAPE |
| **PAUSE** | Menu: 1) Resume, 2) Recalibrate EyeLink, 3) Save & Quit |
| **SET_COMPLETE** | Prompt: "Run another set? [Y/N]" after all trials done |

### Pause Behavior

Press **ESCAPE** at any time during a trial. The current trial completes fully (no data is lost), then the pause menu appears. From the menu you can:
- **Resume** the task at the next trial
- **Recalibrate** EyeLink without restarting
- **Save & Quit** cleanly (resume later by re-running the script)

### Gaze-Gated Fixation

The FIXATION state waits indefinitely for the participant to look at the fixation cross. If the participant steps away, the task naturally pauses at fixation until they return. No trials are wasted.

## Folder Structure

```
colorMotionTask/
  colorMotionTask.m              Main script (state machine dispatcher)
  README.md                      This file
  results/                       Output data (created at runtime)
  funcs/
    taskCfg.m                    All configurable parameters
    buildTrialList.m             Generate shuffled factorial trial list
    states/                      State machine functions
      stateSetup.m                 TRIAL_SETUP state
      stateFix.m                   FIXATION state (gaze-gated)
      stateDots.m                  DOTS state (stimulus + saccade detection)
      stateFeedback.m              FEEDBACK state
      stateITI.m                   ITI state (save data, advance trial)
      statePause.m                 PAUSE state (menu)
      stateSetComplete.m           SET_COMPLETE state (run another set?)
    dots/                        Dot generation and rendering
      generateDots.m               Pre-generate dot positions + colors
      drawDotsFrame.m              Render one frame of dots to screen
      drawTargets.m                Draw left/right saccade targets
    eyelink/                     EyeLink integration
      eyeInit.m                    Initialize EyeLink connection
      eyeCalib.m                   Run EyeLink calibration
      detectSaccade.m              Wait for saccade (fixed-duration mode)
      transferFile.m               Transfer EDF file from EyeLink host
    io/                          Data saving and loading
      saveProgress.m               Auto-save session state after each trial
      loadProgress.m               Load saved session for resume
      saveDotMovies.m              Batch-save dot info (rig_files format)
    utils/                       Geometry and utility helpers
      ang2pix.m                    Visual angle to pixels
      deg2screen.m                 Degrees to screen coordinates
      rectAround.m                 Create rect around center point
      emptyStruct.m                Create empty struct with given fields
      cleanup.m                    Cleanup on error/exit
```

## Configuration

All parameters are in `funcs/taskCfg.m`. Key settings:

### Coherence Levels
```matlab
cfg.coherences = [0, 0.032, 0.064, 0.128, 0.256, 0.512];
```
Both motion and color use the same unsigned levels. Signed coherences (11 levels each) are generated automatically, producing 121 unique conditions.

### Experimental Design
```matlab
cfg.nReps            = 5;     % repetitions per condition (605 trials total)
cfg.dotMovieBatchSize = 100;  % save dot info to disk every N trials
```

### Timing
```matlab
cfg.timing.fixHoldToStart = 0.1;  % gaze hold before trial starts (s)
cfg.timing.fixation       = 0.5;  % pre-stimulus fixation period (s)
cfg.timing.maxRT          = 5.0;  % maximum response time (s)
cfg.timing.fixedDuration  = 0;    % 0 = RT mode; >0 = fixed viewing (s)
cfg.timing.feedbackDur    = 0.3;  % feedback duration (s)
cfg.timing.ITI            = 1.0;  % inter-trial interval (s)
```

### Dot Parameters
```matlab
cfg.dots.aperture = [0 0 10 10];  % [cx, cy, width, height] in degrees
cfg.dots.speed    = 5;            % degrees per second
cfg.dots.density  = 16.7;         % dots per degree^2 per second
cfg.dots.dotSize  = 3;            % pixels
cfg.dots.interval = 3;            % interleaved motion frames
```

### Monitor
```matlab
cfg.monitor.width    = 530;  % monitor width (mm)
cfg.monitor.distance = 600;  % viewing distance (mm)
```

## Data Output

All data is saved to `results/{subjectName}/`:

| File | Contents | When Saved |
|------|----------|------------|
| `sessionState.mat` | Trial data, trial list, subject info, config, current trial index | After every trial |
| `{name}_data.mat` | Same as sessionState.mat (named copy) | After every trial |
| `{name}_dotInfo.mat` | `save_struct` with `dots_struct` per trial (rig_files format) + `screen_struct` | Every 100 trials + pause/finish |
| `{num}_S{seg}_eD.edf` | EyeLink eye movement data | End of session |

### Trial Data Fields

Each entry in `sessionState.trialData{}` contains:

```
motionDir, motionCoh, colorDir, colorCoh     — stimulus parameters
correctTarget                                 — 'left' or 'right'
fixAcquired, fixOn, dotsOn, targetsOn         — timing timestamps
saccadeOn, saccadeLand, feedbackOn, feedbackOff
RT                                            — reaction time (s)
response                                      — 'left', 'right', 'noTarget', 'timeout'
correct                                       — true/false
saccX, saccY                                  — saccade landing coordinates
framesShown                                   — number of dot frames displayed
```

### Dot Info Format (rig_files compatible)

Each entry in `save_struct{}` contains a `dots_struct` with:

```
aperture, direction, coherence, speed, density, dot_size
col_dir, col_coh, interval, show_color1_first, shown_frames
dot_pos    — [ndots x 3 x nFrames] array (x, y, color per dot per frame)
```

## Resume After Interruption

The task auto-saves after every trial. To resume:

1. Re-run `colorMotionTask`
2. Select "No" for first session
3. Select the subject from the list
4. The task picks up at the exact trial where it left off

This also works after a crash or power loss — at most 1 trial of data is lost.
