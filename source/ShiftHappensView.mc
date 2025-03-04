import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Application as App;

function reduse_deg(deg) {
	if (deg<0) 		{	deg += 360; }
	if (deg<0) 		{	deg += 360; }
	if (deg>360)	{	deg -= 360; }
	if (deg>360)	{	deg -= 360; }
	return deg;
}

class ShiftHappensView extends WatchUi.View {

    var _ui = null;
	var _SpeedHistory = new Dynamics(100,false);   // standard 120 (2 min)
	var _CogHistory   = new Dynamics(100, true);   // standard 120 (2 min)  
    var m_posnInfo = null;  
//    var m_COG_deg = 0;
//    var m_Speed_kn = 0;

    function initialize() {
        View.initialize();
        _ui = new ShiftHappensUi();
        _ui.m_WindDirection = Application.Storage.getValue("WindDirection");
    }

    // Read param from app-property
    function getProperties() {
        var WindDirection = Application.Properties.getValue("WindDir");
        WindDirection = WindDirection==null ? 180 : WindDirection;
        self.setWindDir(WindDirection);

        if (Application.Properties.getValue("DrawPolarCogPlot") ) {
            _ui.m_bDrawPolarCogPlot = true;
        } else {
            _ui.m_bDrawPolarCogPlot = false;
        }

    }

    // Read param from app-property
    function setProperties() {
        Application.Properties.setValue("WindDir", self.getWindDir());
        Application.Properties.setValue("DrawPolarCogPlot", _ui.m_bDrawPolarCogPlot);
    }
    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function startStopRecording() as Void {
        System.println("View.startStopRecording()");
        var app = App.getApp();

        if (_ui.m_bRecording) {
            // Stop recording
            _ui.m_bRecording = false;
            app.stopRecording();
            
        } else {
            // Start recording
            _ui.m_bRecording = true;
            app.startRecording();
            _ui._startRecordingTime = new Time.Moment(Time.now().value());
        }
    }

    function setWindDir(WindDir) as Void {
        System.println("View.setWindDir( " + WindDir + " ) " );
        _ui.m_WindDirection = WindDir;
        updateWindDirDiff(0);        
    }
    function getWindDir()  {
        return _ui.m_WindDirection;
    }

    function updateWindDirDiff(diffAngle) as Void {
        // Update Wind-dir
        _ui.m_WindDirection += diffAngle;
//        _ui.m_WindDirection = Application.Storage.getValue("WindDirection");
        _ui.m_WindDirection = Math.round(_ui.m_WindDirection);
        _ui.m_WindDirection = reduse_deg(_ui.m_WindDirection.toLong());
        _ui.m_WindDirStarboard = reduse_deg(_ui.m_WindDirection + (_ui.m_TackAngle/2) );
        _ui.m_WindDirPort = reduse_deg(_ui.m_WindDirection - (_ui.m_TackAngle/2) );
        System.println("View.updateWindDirDiff( " + diffAngle + " )");
        System.println("     m_WindDirection = " + _ui.m_WindDirection);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

 		// Get COG & SOG from PositionInfo
		if(m_posnInfo!=null	){ 
			_ui.m_COG_deg = reduse_deg((m_posnInfo.heading)/Math.PI*180);
		} else {
			_ui.m_COG_deg = 0;
		}
		if(m_posnInfo!=null){
            _ui.m_Speed_kn = m_posnInfo.speed * 1.9438444924406;
		} else {
			_ui.m_Speed_kn = 0;
		}

		//Update Speed-History-array
		if (_ui.m_Speed_kn>-0.000001 && _ui.m_Speed_kn<99.9){
			_SpeedHistory.push(_ui.m_Speed_kn);
		}
		//Update COG-History-array
		_CogHistory.push(_ui.m_COG_deg);


        // Draw the tick marks around the edges of the screen
        _ui.drawHashMarks(dc);
        // Draws a red round record indicator
        _ui.drawRecordIndicator(dc);      
        // Draw North arrow
        _ui.drawNorth(dc);
        // Draw boat
		_ui.drawBoat(dc);
        // Draw laylines
        _ui.drawLaylines(dc);
		//Draw Cog-curve 
		_ui.drawCogPlot(dc, _CogHistory);
        // Draw COG-circle 
		_ui.drawCogDot(dc);
		//Draw speed-curve and SOG-text
		_ui.drawSpeedPlot(dc, _SpeedHistory);        
        // Draw COG-text in a circle
        _ui.drawCOGtext(dc);
        // Draw Time-text
        _ui.drawTimeText(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function setPosition(info) {
        m_posnInfo = info;

//        self.requestUpdate();
    }
}
