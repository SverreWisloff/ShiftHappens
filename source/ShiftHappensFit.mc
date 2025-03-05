//import Toybox.Lang;
//using Toybox.WatchUi;
//using Toybox.FitContributor as Fit;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.ActivityRecording as Record;


// Recording activity to FIT file
// And record to buffer for computation and display
class ShiftHappensFit {

    hidden var _TimerRunning = false;
    hidden var _ActivityRecording = null; // recording session

    function initialize() {
        var deviceSettings = Sys.getDeviceSettings();

        if(deviceSettings.monkeyVersion[0] >= 3 && Activity has :SPORT_SAILING) {
            _ActivityRecording = Record.createSession({:name => "Sailing", :sport => Activity.SPORT_SAILING});    
        } else {
            _ActivityRecording = Record.createSession({:name => "Sailing", :sport => Activity.SPORT_GENERIC});
        }        
    }

    function recordData(positionInfo) {

        if(_TimerRunning) {
       		//TODO Record databto buffer
            //System.println("recordData");
    	}
    }
    
    function onTimerLap() {
        _ActivityRecording.addLap();
        System.println("Lap reset");
    }
    
    function onTimerReset() {

        System.println("Session reset AND Lap reset");
    }
    
    function onTimerPause() {
    	_TimerRunning = false;
    }
    
    function onTimerResume() {
        _TimerRunning = true;
    }
    
    function onTimerStart() {
        _TimerRunning = true;
        _ActivityRecording.start();
    }

    function onTimerStop() {
        _TimerRunning = false;
        _ActivityRecording.stop();
    }    

    function onTimerSave() {
        _TimerRunning = false;
        _ActivityRecording.stop();
        _ActivityRecording.save();
    }    
}