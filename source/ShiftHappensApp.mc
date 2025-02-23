import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Position as Position;
using Toybox.Activity as Activity;

//using Toybox.System;

class ShiftHappensApp extends Application.AppBase {
    hidden var _shFit;
    var m_ShiftHappensView;
    var m_ShiftHappensDelegate;

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
        m_ShiftHappensView.requestUpdate();
    }


    // handle position events
    function onPosition(info) {
        _shFit.recordData(info);

        m_ShiftHappensView.setPosition(info);

        System.println("recordData");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        _shFit.onTimerStop();
        _shFit.onTimerSave();

    	// Save app-property - to next time 
        m_ShiftHappensView.setProperties();

        System.println("onStop() - done for this time");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
		m_ShiftHappensView = new ShiftHappensView();
		m_ShiftHappensDelegate = new ShiftHappensDelegate();
        m_ShiftHappensDelegate.setParentView(m_ShiftHappensView);

		// Read param from app-property
        m_ShiftHappensView.getProperties();

        return [ m_ShiftHappensView, m_ShiftHappensDelegate ];
        //return [ new ShiftHappensView(), new ShiftHappensDelegate() ];
    }

    // Set wind direction can be defined on either port, or starboard close-hauled direction
    function setWinddirFromCloseHauled(starboard) {
        var NewWindDir;
        if (starboard){
            NewWindDir = m_ShiftHappensView.getWindDir() - 45;
        } else {
            NewWindDir = m_ShiftHappensView.getWindDir() + 45;
        }
        System.println("App.setWinddirFromCloseHauled() -  NewWindDir = " + NewWindDir );

        m_ShiftHappensView.setWindDir(NewWindDir);

    }

}

function getApp() as ShiftHappensApp {
    return Application.getApp() as ShiftHappensApp;
}