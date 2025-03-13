import Toybox.Graphics;
import Toybox.Math;



//a class with functionality for drawing an analog clock face, such as clock hands
class ShiftHappensUi {

	//Member variables
    var m_screenShape;
    var m_TackAngle = 90;
    var m_width;
    var m_height;
	var m_bRecording = false;
    var m_WindDirection=0;
    var m_WindDirStarboard=0;
    var m_WindDirPort=0;
    var m_CogDotSize = 8;
    var m_COG_deg=0;
    var m_Speed_kn=0;
    var m_bDrawBoat=true;
    var m_bDrawNWSE=true;
    var m_bDrawSpeedPlot=true;
    var m_bDrawOrthogonalCogPlot=false;
    var m_bDrawPolarCogPlot=true;
    var m_boatScale=1.2;
	var _startRecordingTime = null;

    //=====================
    // Draws a red round record indicator
    //=====================
    public function drawRecordIndicator(dc as Dc) {
        m_width = dc.getWidth();
        m_height = dc.getHeight();

		var timediff;
		if (_startRecordingTime != null) {
			var now = new Time.Moment(Time.now().value());
			timediff = now.value() - _startRecordingTime.value();
		} else {
			timediff = 0;
		}
		//System.println("timediff: " + timediff);

		// Draw a gray circle if recording has been going on for more than 60 seconds, red else
		if (timediff > 60) {
			dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		} else {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		}

		dc.drawCircle(m_width/2*1.5, m_height/2*0.75, 7);

		if (m_bRecording) {
			dc.fillCircle(m_width/2*1.5, m_height/2*0.75, 5);
			dc.drawText(m_width/2*1.5, (m_height/2*0.75)+7, Graphics.FONT_XTINY, "REC", Graphics.TEXT_JUSTIFY_CENTER);
		}

    }

    //=====================
    // Draws the clock tick marks around the outside edges of the screen.
    //=====================
    public function drawHashMarks(dc as Dc) {
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);

        m_width = dc.getWidth();
        m_height = dc.getHeight();

        // Draw hashmarks around the edges of the screen
        var sX, sY;
        var eX, eY;
        var outerRad = m_width / 2;
        var innerRad = outerRad - 9;
        
        // draw 10-deg tick marks.
        for (var i = 0; i < 2 * Math.PI ; i += (Math.PI / 18)) {
            sY = outerRad + innerRad * Math.sin(i);
            eY = outerRad + outerRad * Math.sin(i);
            sX = outerRad + innerRad * Math.cos(i);
            eX = outerRad + outerRad * Math.cos(i);
            dc.drawLine(sX, sY, eX, eY);
        }

        // draw 10-deg tick marks.
        innerRad = outerRad - 5;
        for (var i = 0; i < 2 * Math.PI ; i += (Math.PI / 90)) {
            sY = outerRad + innerRad * Math.sin(i);
            eY = outerRad + outerRad * Math.sin(i);
            sX = outerRad + innerRad * Math.cos(i);
            eX = outerRad + outerRad * Math.cos(i);
            dc.drawLine(sX, sY, eX, eY);
        }
            
    }
    //=====================
    // Draws North 
    //=====================
    function drawNorth(dc as Dc) {
    	if (m_bDrawNWSE==false){
    		return;
    	}
    	
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		var fontHeight = dc.getFontHeight(Graphics.FONT_TINY); 

		var i = -(m_WindDirection+90)/180.0 * Math.PI;
        var X = ((m_width/2)-20) * Math.cos(i);
        var Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
 		
		i = -(m_WindDirection)/180.0 * Math.PI;
        X = ((m_width/2)-20) * Math.cos(i);
        Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "E", Graphics.TEXT_JUSTIFY_CENTER);

		i = -(m_WindDirection-90)/180.0 * Math.PI;
        X = ((m_width/2)-20) * Math.cos(i);
        Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "S", Graphics.TEXT_JUSTIFY_CENTER);

		i = -(m_WindDirection+180)/180.0 * Math.PI;
        X = ((m_width/2)-20) * Math.cos(i);
        Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "W", Graphics.TEXT_JUSTIFY_CENTER);
    }

    //=====================
    // Draws COG-dot 
    //=====================
    function drawCogDot(dc as Dc) {
		// X,Y refers to origo i face-centre
		var i = -(m_WindDirection+90-m_COG_deg)/180.0 * Math.PI;
        var X = ((m_width/2)-m_CogDotSize) * Math.cos(i);
        var Y = ((m_height/2)-m_CogDotSize) * Math.sin(i);
		
//		System.println("drawNorth : WindDirection=" + WindDirection + " i="+i);
		
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    	dc.fillCircle(X + (m_width/2), Y + (m_height/2), m_CogDotSize+2);
    	dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    	dc.fillCircle(X + (m_width/2), Y + (m_height/2), m_CogDotSize);
    }	
    //=====================
    // Draws  Wind-arrow
    //=====================
    function drawWindArrow(dc as Dc) {
		//  -----------------> x
		//  |    10
		//  |   ---
		//  |   | | 10
		//  |  -- --
		//  |  \   / 10
		//  |   \ /
		//  y    V
		var arrayArrow = [ 
				[+  0,   0], 
				[+  5,+  0], 
				[+  5,+ 10], 
				[+ 10,+ 10], 
				[+  0,+ 20], 
				[- 10,+ 10], 
				[-  5,+ 10], 
				[-  5,+  0], 
				[+  0,+  0] 
			];
		// Scaling the size of the arrow
		var arrowScale = m_width/200.0;
		for (var i=0; i<arrayArrow.size(); i+=1){
			arrayArrow[i][0] = arrayArrow[i][0] * arrowScale;
			arrayArrow[i][1] = arrayArrow[i][1] * arrowScale;
		}
		// Move/translate the arrow
		var dX=m_width/2;
		var dY=40;
		for (var i=0; i<arrayArrow.size(); i+=1){
			arrayArrow[i][0] = arrayArrow[i][0] + dX;
			arrayArrow[i][1] = arrayArrow[i][1] + dY;
		}
		// Draw the arrow
		var nextX, nextY, prevX, prevY;
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		prevX = arrayArrow[0][0];
		prevY = arrayArrow[0][1];
		for (var i=1; i<arrayArrow.size(); i+=1){
			nextX = arrayArrow[i][0];
			nextY = arrayArrow[i][1];
			dc.drawLine( prevX, prevY, nextX, nextY);
			prevX=nextX;
			prevY=nextY;
		}
	}

    function computeBoatPolygon(boatScale)  {
		
		var arrayBoat = [ 
				[+  0,- 50], 
				[+  6,- 40], 
				[+ 10,- 30], 
				[+ 13,- 20], 
				[+ 15,- 10], 
				[+ 16,-  0], 
				[+ 17,+ 20], 
				[+ 17,+ 30], 
				[+ 16,+ 40], 
				[+ 13,+ 50], 
				[- 13,+ 50], 
				[- 16,+ 40], 
				[- 17,+ 30], 
				[- 17,+ 20], 
				[- 16,-  0], 
				[- 15,- 10], 
				[- 13,- 20], 
				[- 10,- 30], 
				[-  6,- 40], 
				[-  0,- 50] 
			];

		//Scaling the size of the boat
		for (var i=0; i<arrayBoat.size(); i+=1){
			arrayBoat[i][0] = arrayBoat[i][0] * boatScale;
			arrayBoat[i][1] = arrayBoat[i][1] * boatScale;
		}
		return arrayBoat;
	}

    //=====================
    // Draws  Boat
    //=====================
    function drawBoat(dc as Dc) {
    
    	if (!m_bDrawBoat){
	    	return;
		}
		
		// X,Y refers to origo i face-centre
		var WD = -(m_WindDirection+90-m_COG_deg)/180.0 * Math.PI;
		WD = WD + Math.PI/2;
		
    	//Draw Boat
    	dc.setPenWidth(5);
    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

		var arrayBoat = computeBoatPolygon(m_boatScale);

		var X = arrayBoat[0][0];
		var Y = arrayBoat[0][1];
		var COS = Math.cos(WD);
		var SIN = Math.sin(WD); 

		moveToOrigoC( dc, (X*COS) - (Y*SIN), (X*SIN) + (Y*COS) );  
	
		for( var i = 1; i < arrayBoat.size(); i += 1 ) {
			X = arrayBoat[i][0];
			Y = arrayBoat[i][1];
			lineToOrigoC( dc, (X*COS) - (Y*SIN), (X*SIN) + (Y*COS) );
		}

    }

    //================================
    //Draw laylines
    //================================
    function drawLaylines(dc as Dc){
		// Draw laylines
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		dc.setPenWidth(2);
		moveToOrigoC(dc, -m_width*Math.sin(Math.PI/4), -m_height*Math.sin(Math.PI/4));
		lineToOrigoC(dc, 0, 0);
		lineToOrigoC(dc,  m_width*Math.sin(Math.PI/4), -m_height*Math.sin(Math.PI/4));
		dc.drawArc( m_width/2, m_height/2, m_height/2-20, dc.ARC_CLOCKWISE, 180-m_TackAngle/2, m_TackAngle/2);
        
		// Draw numbers for wind directions
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		//m_WindDirection = me.reduse_deg(m_WindDirection); // !!! Why?
        dc.drawText(m_width/2, 5, Graphics.FONT_TINY, m_WindDirection , Graphics.TEXT_JUSTIFY_CENTER);

		var cos45 = Math.cos(Math.PI/4);
        dc.drawText(m_width/2-m_width/2*cos45+15, m_height/2-m_height/2*cos45, Graphics.FONT_TINY, m_WindDirPort, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(m_width/2+m_width/2*cos45-15, m_height/2-m_height/2*cos45, Graphics.FONT_TINY, m_WindDirStarboard, Graphics.TEXT_JUSTIFY_RIGHT);
    }


    //================================
    // Draws speed-histoy-plot
	//================================
	function drawSpeedPlot(dc, SpeedHistory){
		var plotWidth  = (m_width/2)+5;
		var plotHeight = 35;

    	if (m_bDrawSpeedPlot){
			SpeedHistory.drawPlot(10, m_height/2+33, plotWidth, plotHeight, dc);

			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawText(m_width*0.75, m_height/2+33, Graphics.FONT_SMALL, m_Speed_kn.format("%.1f") + " kn", Graphics.TEXT_JUSTIFY_CENTER);
		} else {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawText(m_width/2, m_height/2+33, Graphics.FONT_SMALL, m_Speed_kn.format("%.1f") + " kn", Graphics.TEXT_JUSTIFY_CENTER);
		}
	}

    //================================
    // Draws Cog-histoy-plot
	//================================
	function drawCogPlot(dc, CogHistory){
		var plotWidth=m_width/2;
		var plotHeight=35;


		//Draw orthogonal COG-plot
    	if (m_bDrawOrthogonalCogPlot){
			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(2);
			CogHistory.drawPlot(10, m_height/2+33, plotWidth, plotHeight, dc);
		}

		//Draw polar COG-plot
    	if (m_bDrawPolarCogPlot){
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(4);
			CogHistory.drawPolarPlot(dc, m_width, m_height, m_WindDirection);
			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(2);
			CogHistory.drawPolarPlot(dc, m_width, m_height, m_WindDirection);
		}
	}


	// ==========================================
    // Draw COG-text in a circle
	// ==========================================
	function drawCOGtext(dc as Dc){
		var fontHeight = dc.getFontHeight(Graphics.FONT_TINY); 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.fillCircle(m_width/2, m_height/2, 25);
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
        dc.drawCircle(m_width/2, m_height/2, 25);
        
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
        dc.drawText(m_width/2, m_height/2-fontHeight/2, Graphics.FONT_TINY, m_COG_deg.toNumber() , Graphics.TEXT_JUSTIFY_CENTER);
    }

	// ==========================================
    // Draw Time-text
	// ==========================================
    function drawTimeText(dc as Dc) {
        var myTime = System.getClockTime(); // ClockTime object
        var myTimeText = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(m_width/2, m_height/2+70, Graphics.FONT_XTINY, myTimeText, Graphics.TEXT_JUSTIFY_CENTER);
    }



	// ==========================================
	// DrawLine functions in origo ref-syst
	// ==========================================
	var prevX=0;
	var prevY=0;
    function moveToOrigoC(dc, x, y) {
		prevX=x;
		prevY=y;
    }
    function lineToOrigoC(dc, nextX, nextY) {
    	dc.drawLine( (m_width/2) + prevX, (m_height/2) + prevY, (m_width/2) +nextX, (m_height/2) + nextY);
		prevX=nextX;
		prevY=nextY;
    }    

}