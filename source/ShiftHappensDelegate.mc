import Toybox.Lang;
import Toybox.WatchUi;

class ShiftHappensDelegate extends WatchUi.BehaviorDelegate {
    var _parentView=null;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function setParentView(parentView) {
        _parentView = parentView;
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new ShiftHappensMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Detect Menu button input
    function onKey(keyEvent) {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 
        //KEY_DOWN, 
        if (keyEvent.getKey()==KEY_ENTER){
        	//Start stop recording
            _parentView.startStopRecording();
            System.println("KEY_ENTER");
        }
        else if (keyEvent.getKey()==KEY_UP){
	        //Press UP to increase WindDirection with 5 degrees
            _parentView.updateWindDirDiff(-5);
            System.println("KEY_UP");
        }
        else if (keyEvent.getKey()==KEY_DOWN){
	        //Press DOWN to decrease WindDirection with 5 degrees
            _parentView.updateWindDirDiff(5);
            System.println("KEY_DOWN");
        }
        else if (keyEvent.getKey()==KEY_ESC){
            // End application
            System.println("KEY_ESC");
            WatchUi.pushView(new Toybox.WatchUi.Confirmation("Exit app?"), new ConfirmExitDelegate(), WatchUi.SLIDE_DOWN);
            //System.exit();
        }

        return true;
    }

}


class ConfirmExitDelegate extends WatchUi.ConfirmationDelegate
{
	function initialize()
    {	
        ConfirmationDelegate.initialize();
    }
    
    function onResponse(value)
    {
        if( value == CONFIRM_YES )
        {	
            System.println("System.exit()");
            System.exit();
        }
    }
}