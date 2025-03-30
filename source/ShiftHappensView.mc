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
    var _posnInfo = null; 
    var _kf; 
//    var m_COG_deg = 0;
//    var m_Speed_kn = 0;

    function initialize() {
        View.initialize();
        _ui = new ShiftHappensUi();
        _ui.m_WindDirection = Application.Storage.getValue("WindDirection");

var dt = 1.0;  // Time step
var u_x = 0.1;  // Acceleration in x-direction
var u_y = 0.1;  // Acceleration in y-direction
var std_acc = 1.0;  // Process noise magnitude
var x_std_meas = 5.0;  // Measurement noise standard deviation in x-direction
var y_std_meas = 5.0;  // Measurement noise standard deviation in y-direction
_kf = new KalmanFilter(dt, u_x, u_y, std_acc, x_std_meas, y_std_meas);

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

    function setWindDirDiff(diffAngle) as Void {
        setWindDir(_ui.m_WindDirection + diffAngle);
    }
    function setWindDir(WindDir) as Void {
        _ui.m_WindDirection = WindDir;
        updateWindDir();        
        System.println("View.setWindDir( " + WindDir + " ) " );
    }
    function getWindDir()  {
        return _ui.m_WindDirection;
    }
    function getCOG_deg()  {
        return _ui.m_COG_deg;
    }

    function updateWindDir() as Void {
        _ui.m_WindDirection = Math.round(_ui.m_WindDirection);
        _ui.m_WindDirection = reduse_deg(_ui.m_WindDirection.toLong());
        _ui.m_WindDirStarboard = reduse_deg(_ui.m_WindDirection + (_ui.m_TackAngle/2) );
        _ui.m_WindDirPort = reduse_deg(_ui.m_WindDirection - (_ui.m_TackAngle/2) );
        System.println("View.updateWindDir:: Stbrd=" + _ui.m_WindDirStarboard + " WindDir=" + _ui.m_WindDirection + " Port=" + _ui.m_WindDirPort );
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        try {

            // Get COG & SOG from PositionInfo
            if(_posnInfo!=null	){ 
                _ui.m_COG_deg = reduse_deg((_posnInfo.heading)/Math.PI* 180);
                var myLocation = _posnInfo.position.toDegrees();
                //var measurement = [myLocation[0], myLocation[1]];
                if (!_kf._bInitPosSet){
                    _kf.setInitPos(myLocation[0], myLocation[1]);
                }
                var coord = latLonToWebMercator(myLocation[0], myLocation[1]);
                var predicted = _kf.predict();
                var updated = _kf.update(coord["x"], coord["y"]);
                var knot = _kf.getVelocityKnot();
                var heading = _kf.getHeadingDeg();
                System.println("Predicted=" + predicted + ", Updated=" + updated + ", Heading=" + heading + " knot:" + knot);
            } else {
                _ui.m_COG_deg = 0;
            }
            if(_posnInfo!=null){
                _ui.m_Speed_kn = _posnInfo.speed * 1.9438444924406;
            } else {
                _ui.m_Speed_kn = 0;
            }
        }
        catch (e) {
            System.println("Error in KalmanFilter: " + e);
        }
		//Update Speed-History-array
		if (_ui.m_Speed_kn>-0.000001 && _ui.m_Speed_kn<99.9){
			_SpeedHistory.push(_ui.m_Speed_kn);
		}
		//Update COG-History-array
		_CogHistory.push(_ui.m_COG_deg);


        // Draw the tick marks around the edges of the screen
        _ui.drawHashMarks(dc);
        // Draw the wind arrow
        _ui.drawWindArrow(dc);
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
        _posnInfo = info;

//        self.requestUpdate();
    }
}
