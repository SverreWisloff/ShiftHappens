import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Position as Position;
using Toybox.Activity as Activity;

//using Toybox.System;

class ShiftHappensApp extends Application.AppBase {
    hidden var _shFit;
    var _ShiftHappensView;
    var _ShiftHappensDelegate;

    function initialize() {
        AppBase.initialize();

        _shFit = new ShiftHappensFit();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {

        // Start a timer/thread to update the view every second
		var secTimer = new Timer.Timer();
		secTimer.start(method(:update), 1000, true);        

        // Start a thread witch enable location events
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        
        // Start the recording of a activity-session to the FIT-file
        // _shFit.onTimerStart();

    }

    function startRecording() as Void {
        _shFit.onTimerStart();
    }
    function stopRecording() as Void {
        _shFit.onTimerStop();
    }

    function update() {
        _ShiftHappensView.requestUpdate();
    }


    // handle position events
    function onPosition(info) {
        _shFit.recordData(info);

        _ShiftHappensView.setPosition(info);

        //System.println("recordData");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        _shFit.onTimerStop();
        _shFit.onTimerSave();

    	// Save app-property - to next time 
        _ShiftHappensView.setProperties();

        System.println("onStop() - done for this time");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
		_ShiftHappensView = new ShiftHappensView();
		_ShiftHappensDelegate = new ShiftHappensDelegate();
        _ShiftHappensDelegate.setParentView(_ShiftHappensView);

		// Read param from app-property
        _ShiftHappensView.getProperties();

        return [ _ShiftHappensView, _ShiftHappensDelegate ];
        //return [ new ShiftHappensView(), new ShiftHappensDelegate() ];
    }

    // Set wind direction can be defined on either port, or starboard close-hauled direction
    function setWinddirFromCloseHauled(starboard) {
        var NewWindDir;
        if (starboard){
            NewWindDir = _ShiftHappensView.getCOG_deg() - 45;
        } else {
            NewWindDir = _ShiftHappensView.getCOG_deg() + 45;
        }
        System.println("App.setWinddirFromCloseHauled() -  NewWindDir = " + NewWindDir );

        _ShiftHappensView.setWindDir(NewWindDir);

    }

}

function getApp() as ShiftHappensApp {
    return Application.getApp() as ShiftHappensApp;
}