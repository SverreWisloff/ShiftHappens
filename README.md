# Shift Happens

_A brief description of what this project does and who it's for._

This is a further development of the [TackingMaster](https://github.com/SverreWisloff/TackingMaster) project. This new version will save activity to FIT file, allow settings from the Connect app, and support for newer watches.

Perhaps the app will also be expanded with a better filter, animations, saving key sailing-metrics to a FIT file, calculate target speed, and integrate with a wind instrument in the future?

## Purpose

This is a simple app for Garmin watches that provides useful information for sailboats that do not have wind instruments. Set wind direction and read close-hauled direction, course over ground and speed. Observe wind-shifts and speed-changes, and see the consequences and make good decisions.

## Installation

_Instructions on how to install and set up the project._

The app can be installed by the Garmin Connect Store. LINK-TODO

## Usage

### Screen display:
- Speed. The green number is speed. 
- Speed changes. Plot is displayed for historical speed changes.
- Course over ground. In the center circle, course/heading over ground is displayed in yellow. The yellow dot, and gray boat show your course over ground direction. 
- Course over ground changes. Plot is displayed for historical course-shifts, also in yellow.
- Wind direction, white number at the top
- Red filled dot indicate recoring av activity is on
- Close-hauled direction

### Buttons:
- **Up**: wind direction adjusting by 5 deg
- **Down**: wind direction adjusting by 5 deg
- **Menu** (hold up): define wind direction by either port, or starboard close-hauled direction
- **Start/stop**: start and stop recording to activity-session (FIT)
- **Back/lap**: Stop recording and exit app

### Ideas:
- Storing sail-data to FIT-File (AWS, AWA)
- Get wind-dir and wind-speed from ext wind-instrument
- Computing target speed

## Inspiration
- [TackingMaster](https://github.com/SverreWisloff/TackingMaster)
- [Yachtsman](https://apps.garmin.com/apps/ee6389b1-df4a-45be-b045-b912be91e256) Garmin watch app.
- [SailingTools](https://github.com/pintail105/SailingTools)
- [Yet-Another-Sailing-App](https://github.com/Laverlin/Yet-Another-Sailing-App)

## Architectural Sketch
````
+-------------------+      +-------------------+
| ShiftHappensApp   |<---->| ShiftHappensFit   |
|-------------------|      +-------------------+
| + initialize()    |      | + onTimerStart()  |
| + onStart(state)  |      | + recordData(info)|
| + onPosition(info)|      +-------------------+
| + onStop(state)   |      
| + getInitialView()|      +--------------------+
|                   |----->|ShiftHappensDelegate|
+-------------------+      +--------------------+
        |             
        v
+------------------+      +-------------------------+
| ShiftHappensView |----->| _SpeedHistory (Dynamics)| 
+------------------+      +-------------------------+
| + initialize()   |      +-------------------------+
| + onLayout(dc)   |----->| _CogHistory (Dynamics)  | 
| + onShow()       |      +-------------------------+
| + onUpdate(dc)   |
| + onHide()       |
| + setPosition(info)|
+------------------+
        |
        v
+------------------+
| ShiftHappensUi   |
|------------------|
| + drawBoat(dc)   |
| + draw...(dc)    |
+------------------+
````

## License

_Include the project's license information._

## Versions

1.0
- copy code from TacingAssist
- Save activity to FIT file
- Settings from the Connect app
- Support for fenix 6 and 7 watches. 

## Notes to self while coding
- [SunEclipticAnalog](https://github.com/SverreWisloff/SunEclipticAnalog?tab=readme-ov-file#notes-to-self-while-coding)
- [SunFacing](https://github.com/SverreWisloff/SunFacing?tab=readme-ov-file#notes-to-self-while-coding)
- xxx

## TODO
- [] Scaling all graphics by screen-size
        - 208: Forerunner 55
        - 218: fēnix 5S
        - 240: fēnix 5
        - 260: fēnix 6
        - 280: fēnix 7X Pro
        - 390: Forerunner® 165
        - 416: fēnix 8 43mm
        - 454: fēnix 8 47mm
- [] Functions: Storing sail-data to FIT-File
- [] Get wind-dir and wind-speed from ext wind-instrument
- [] Computing target speed
- [] Supporting Devices: enduro, fr965, fr955, fr945, fr945lte, fr265, fr265s
- [x] Display Record-indicator
- [x] Supporting Devices: fenix5, fenix5plus, fenix5x, fenix5xplus, fenix6, fenix6pro, fenix6s, fenix6spro, fenix6xpro, fenix7, fenix7pro, 
- [x] Functions: Set wind direction. The up and down buttons can be used for adjusting the wind direction with 5 degree increments.
- [x] Functions: The tack angle is defined to 90 degrees.
- [x] Functions: Storing activity to FIT-file
- [x] When starting the app, recording will start an activity with sport-type sailing
- [x] Display Speed. The green number is speed. 
- [x] Display Speed changes. Plot is displayed for historical speed changes.
- [x] Display Course over ground. In the center circle, course over ground is displayed in yellow. 
- [x] Display Course over ground changes. Plot is displayed for historical course-shifts.
- [x] Display Read close-hauled direction
- [x] Display The direction where the wind comes from is allways facing up on the clock, and the top number is the direction against the wind-eye. 
- [x] Display The blue "N" shows the direction to north. 
- [x] Display The yellow dot, and gray boat show your course over ground direction.
- [x] Functions: By pressing menu (hold up button) the wind direction can be defined on either port, or starboard close-hauled direction. There are also some settings available from the menu
