import Toybox.Graphics;
import Toybox.Math;



//a class with functionality for drawing an analog clock face, such as clock hands
class ShiftHappensUi {

	//Member variables
    var m_screenShape;
    var m_TackAngle = 90;
    var m_posnInfo = null;
    var m_width;
    var m_height;
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
    function drawNorth(dc) {
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
    function drawCogDot(dc) {
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
    // Draws  Boat
    //=====================
    function drawBoat(dc) {
    
    	if (!m_bDrawBoat){
	    	return;
		}
		
		// X,Y refers to origo i face-centre
		var WD = -(m_WindDirection+90-m_COG_deg)/180.0 * Math.PI;
		WD = WD + Math.PI/2;
		
    	//Draw Boat
    	dc.setPenWidth(5);
    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

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
		m_boatScale=1.2;
		for (var i=0; i<arrayBoat.size(); i+=1){
			arrayBoat[i][0] = arrayBoat[i][0] * m_boatScale;
			arrayBoat[i][1] = arrayBoat[i][1] * m_boatScale;
		}
		
		var X = arrayBoat[0][0];
		var Y = arrayBoat[0][1];
		var COS = Math.cos(WD);
		var SIN = Math.sin(WD); 

		moveToOrigoC( dc, (X*COS) - (Y*SIN), (X*SIN) + (Y*COS) );    	
		
		for( var i = 1; i < 20; i += 1 ) {
			X = arrayBoat[i][0];
			Y = arrayBoat[i][1];
			lineToOrigoC( dc, (X*COS) - (Y*SIN), (X*SIN) + (Y*COS) );
		}

    }

    //================================
    //Draw laylines
    //================================
    function drawLaylines(dc){
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
        dc.drawText(m_width/2, m_height/2-115, Graphics.FONT_TINY, m_WindDirection , Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(m_width/5, m_height/2-70, Graphics.FONT_TINY, m_WindDirPort, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(m_width/5*4, m_height/2-70, Graphics.FONT_TINY, m_WindDirStarboard, Graphics.TEXT_JUSTIFY_RIGHT);
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
	function drawCOGtext(dc){
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
    function drawTimeText(dc){
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