//using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Math;
using Toybox.Graphics;


//           0    
//           |    
//        4  |  1 
//270 --------------- 90
//        3  |  2 
//           |
//          180    
function Quadrant( degree )
{
	if      ( (degree>=  0) && (degree< 90) ) { return 1; }
	else if ( (degree>= 90) && (degree<180) ) { return 2; }
	else if ( (degree>=180) && (degree<270) ) { return 3; }
	else if ( (degree>=270) && (degree<360) ) { return 4; }
	else {return -1;}
}

class Dynamics 
{
	var _Size = 10; // standard 120 (2 min)
	var _aData = [];
	var _aDataSmooth = [];
	var _nSmoothingWith = 2; // 0=off, 2=two points in both ways
	var _NowPointer; 
	var _PlotMaxData;
	var _PlotMinData;
	var _bCOG;

	var _PrevWatchX;
	var _PrevWatchY;

//------------------------------------------------------
// i     0    1    2    3    4    5    6    7    8    9
//COG  3.9  3.8  3.7  3.6  3.5  3.4  999  999  999  999
//                                L NowPointer (Last data-point)
//------------------------------------------------------
//
//

    // Dummy-value i data-array = 999.0
	// bCOG=true: 360 deg-data
	function initialize(Size, bCOG) {
		var i;
		_Size = Size;
		_bCOG = bCOG;
		me._NowPointer = _Size;
		//System.println("Dynamics::initialize() - _Size=" + _Size );
		for( i = 0; i < _Size; i += 1 ) {
			_aData.add(999.00001);
			_aDataSmooth.add(999.00001);
		}
		_PlotMaxData=2.0;
		_PlotMinData=0.0;
		//me.Print();
	}

	// Make som demodata and fill the hole array with data from 1 to 3 
	function fillDemData(){
		for( var i = 0; i < _Size+3; i += 1 ) {
			var demodata = Math.PI*2.0;
			demodata = Math.sin( demodata * i / _Size);
			demodata = demodata + 2;
			me.push( demodata );
		}	
	}
	
	// Insert latest data
	function push(newData)
	{
		//System.println("Dynamics::push(" + newData + ")  -- _NowPointer=" + _NowPointer);
		
		_NowPointer+=1;
		if (_NowPointer>=_Size){
			_NowPointer=0;
//			System.println("Dynamics::push(" + newData + ")  -- _NowPointer=" + _NowPointer + " - Passing buffer-limit - new beginn at top");
		}

		//System.println("Dynamics::push(" + newData + ")  -- _NowPointer=" + _NowPointer);

		_aData[_NowPointer] = newData;

		smoothingWeightedMovingAverage();

	}

	function smoothingWeightedMovingAverage(){
	// Weighted moving average : Weights: 1-2-1
	//Algorithm:
	// Smoothed(prev2) = (prev4*1,5 + prev3*2 + prev2*3 + prev1*2 + this*1,5) / 10
	// Smoothed(prev1) = (prev2 + prev1*2 + this) / 4
	// Smoothed(this) = This
		var Prev1Pointer;
		var Prev2Pointer;
		var Prev3Pointer;
		var Prev4Pointer;
		var DataPrev1;
		var DataPrev2;
		var DataPrev3;
		var DataPrev4;
		var SmootedDataPrev1;
		var SmootedDataPrev2;

		var newData = _aData[_NowPointer];

		// Find Prev1Pnt
		if (_NowPointer==0){Prev1Pointer = _Size-1;}
		else {Prev1Pointer = _NowPointer-1;}
		
		// Find Prev2Pnt
		if (Prev1Pointer==0){Prev2Pointer = _Size-1;}
		else {Prev2Pointer = Prev1Pointer-1;}

		// Find Prev3Pnt
		if (Prev2Pointer==0){Prev3Pointer = _Size-1;}
		else {Prev3Pointer = Prev2Pointer-1;}

		// Find Prev4Pnt
		if (Prev3Pointer==0){Prev4Pointer = _Size-1;}
		else {Prev4Pointer = Prev3Pointer-1;}

		DataPrev1 = _aData[Prev1Pointer];
		DataPrev2 = _aData[Prev2Pointer];
		DataPrev3 = _aData[Prev3Pointer];
		DataPrev4 = _aData[Prev4Pointer];

		if (DataPrev1>900){DataPrev1=newData;}
		if (DataPrev2>900){DataPrev2=newData;}
		if (DataPrev3>900){DataPrev3=newData;}
		if (DataPrev4>900){DataPrev4=newData;}

		if (_bCOG)
		{
			var Quad0 = Quadrant(newData);
			var Quad1 = Quadrant(DataPrev1);
			var Quad2 = Quadrant(DataPrev2);
			var Quad3 = Quadrant(DataPrev3);
			var Quad4 = Quadrant(DataPrev4);
			
			//Er alle COG-data som skal brukes i glatting i quadrant 1 eller 4?
			if ( (Quad0==1 || Quad0==4) 
				&& (Quad1==1 || Quad1==4)
				&& (Quad2==1 || Quad2==4)
				&& (Quad3==1 || Quad3==4)
				&& (Quad4==1 || Quad4==4) )
			{
					if (Quad0==1) { newData = newData + 360.0; }
					if (Quad1==1) { DataPrev1 = DataPrev1 + 360.0; }
					if (Quad2==1) { DataPrev2 = DataPrev2 + 360.0; }
					if (Quad3==1) { DataPrev3 = DataPrev3 + 360.0; }
					if (Quad4==1) { DataPrev4 = DataPrev4 + 360.0; }
			}	
		}
		
		if (_nSmoothingWith==2){
			SmootedDataPrev2 = (DataPrev4*1.5 + DataPrev3*2.0 + DataPrev2*3.0 + DataPrev1*2.0 + newData*1.5) / 10.0;
			SmootedDataPrev1 = (DataPrev2 + DataPrev1*2.0 + newData) / 4.0;
			_aDataSmooth [Prev2Pointer] = SmootedDataPrev2;
			_aDataSmooth [Prev1Pointer] = SmootedDataPrev1;
			_aDataSmooth [_NowPointer] = newData;
		} else if (_nSmoothingWith==0){
			_aDataSmooth [_NowPointer] = newData;
		}
	}

	function getData(sinceNow){
		if (sinceNow>_Size || sinceNow<0){return 0.0;}

		var i = _NowPointer-sinceNow;

		if (i<0){
			i = _Size + (i);
		}

		if (i>_Size || i<0){return 0.0;}

		return _aData[i];
	}
	
	function getSmoothedData(sinceNow){
		if (sinceNow>_Size || sinceNow<0){
			System.println("getSmoothedData() - SKAL IKKE SKJE");
			return 0.0;
		}

		var i = _NowPointer-sinceNow;

		if (i<0){
//			System.println("getSmoothedData() - Passerer buffer");
			i = _Size + (i);
		}

		if (i>_Size || i<0){
			System.println("getSmoothedData() - SKAL HELLER IKKE SKJE");
			return 0.0;
		}

		return _aDataSmooth[i];
	}

	// Get smallest data-point
	function Min()
	{
		var Minimum=99;
		for( var i = 0; i < _aData.size(); i += 1 ) {
        	if (_aData[i]<Minimum){Minimum=_aData[i];}
        }
        return Minimum;
	}

	// Get largest data-point
	function Max()
	{
		var Maximum=0;
		for( var i = 0; i < _aData.size(); i += 1 ) {
        	if (_aData[i]>Maximum && _aData[i]<900){Maximum=_aData[i];}
        }
        return Maximum;
	}

	function Print()
	{
		System.println("Dynamics::Print() - _NowPointer=" + me._NowPointer );
		for( var i = 0; i < _aData.size(); i += 1 ) {
        	System.print("Dynamics[" + i + "]=" + _aData[i] + " ");
			if (i==me._NowPointer){
				System.println("<-");
			} else {
				System.println(" ");
			}
        }
	}

	function PrintReverse()
	{
		System.println("Dynamics::PrintReverse()" );
		for( var sinceNow = 0; sinceNow < _Size; sinceNow += 1 ) {
        	var Data = getData(sinceNow);
			System.println("sinceNow=" + sinceNow + " Data=" + Data);
        }
	}

	
	//Draw smoothed data as a line in a polar diagram
	function drawPolarPlot(dc, width, height, WindDirection)
	{
		//draw data
		for( var sinceNow = 0; sinceNow < _Size; sinceNow += 1 ) {
        	var Data = getSmoothedData(sinceNow);
			if (Data<900 )//&& Data>0.0 && Data<360.0)
			{
				plotPolarCoordToWatchCoord(dc, width, height, WindDirection, Data, sinceNow);
			} else {
				//System.println("ERROR : drawPolarPlot() - Data=" + Data );
			}
		}

	}
	function plotPolarCoordToWatchCoord(dc, width, height, WindDirection, Data, sinceNow)
	{
		// X,Y refers to origo i face-centre
		var i = -(WindDirection+90-Data)/180.0 * Math.PI;
        var X = ((width  / 2)-5) * ((_Size.toFloat()-sinceNow)/_Size) * Math.cos(i);
        var Y = ((height / 2)-5) * ((_Size.toFloat()-sinceNow)/_Size) * Math.sin(i);
		var WatchX = X + (width / 2);
		var WatchY = Y + (height / 2);

		if (_PrevWatchX==null){
			_PrevWatchX = WatchX;
			_PrevWatchY = WatchY;
		}
		if (sinceNow==0){
			_PrevWatchX = WatchX;
			_PrevWatchY = WatchY;
		} else if (sinceNow<_Size-1){
			dc.drawLine(_PrevWatchX, _PrevWatchY, WatchX, WatchY);
//    	dc.fillCircle(X + (width/2), Y + (height/2), 2);
		}

		_PrevWatchX = WatchX;
		_PrevWatchY = WatchY;
	}

	//Draw smoothed data as a line in a trad. orthogonal diagram
	//DX, DY : Upper left corner of plot
	//width, height: width and height of plot
	function drawPlot(DX, DY, width, height, dc)
	{
	    //Draw Rectangle / axis / fill black bakground
//		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
//		dc.fillRectangle(DX, DY, width, height);
//		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_LT_GRAY);
//		dc.drawRectangle(DX, DY, width, height);

		var dataMin = me.Min();
		var dataMax = me.Max();

		if ( (dataMax-dataMin) < 1.4)
		{	// Alle data har neste samme fart. Setter nedre og øvre akse til 1.4 kn - Upper limit for zoom of speed plot
			var gjennomsnittsfart = (dataMin + dataMax)/2.0;
			_PlotMinData = gjennomsnittsfart - 0.7;
			_PlotMaxData = gjennomsnittsfart + 0.7;
		}
		else
		{	// Normalsituasjon. Justerer nedre og øvre akse
			if (_PlotMinData < dataMin  ){
				_PlotMinData = _PlotMinData + 0.05;
			} else {
				_PlotMinData = dataMin; 
			}

			if ( (_PlotMaxData > dataMax)  ){
				_PlotMaxData = _PlotMaxData - 0.05;
			} else {
				_PlotMaxData = dataMax;
			}
		}
		//System.println("Dynamics::drawPlot() - Min=" + _PlotMinData.format("%.1f") + " Max=" + _PlotMaxData.format("%.1f") + " Max-Min=" + (_PlotMaxData-_PlotMinData).format("%.1f"));
		
		//Draw a help line to nearest long
		var DisplayAbsicce = (_PlotMaxData + _PlotMinData ) / 2.0;
		DisplayAbsicce = DisplayAbsicce.toLong();
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, DisplayAbsicce, 0);
		plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, DisplayAbsicce, _Size-2);
		
		if (DisplayAbsicce+1 < _PlotMaxData){
			plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, DisplayAbsicce+1, 0);
			plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, DisplayAbsicce+1, _Size-2);
		}
		if (DisplayAbsicce-1 > _PlotMinData){
			plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, DisplayAbsicce-1, 0);
			plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, DisplayAbsicce-1, _Size-2);
		}

//		System.println("dataMax="+ dataMax + " dataMin="+ dataMin + " _PlotMaxData=" + _PlotMaxData + " DisplayAbsicce=" + DisplayAbsicce);
		
		//draw data-points into plot
		var sinceNow;
		var Data;
		dc.setPenWidth(7);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		for( sinceNow = 0; sinceNow < _Size-1; sinceNow += 1 ) {
        	Data = getSmoothedData(sinceNow);
			if (Data<900){
				plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, Data, sinceNow);
			}
		}
		dc.setPenWidth(3);
		dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

		for( sinceNow = 0; sinceNow < _Size; sinceNow += 1 ) {
       	   	Data = getSmoothedData(sinceNow);
			if (Data<900){
				plotCoordToWatchCoord(dc, DX, DY, width, height, _PlotMaxData, _PlotMinData, Data, sinceNow);
			}
		}
//		me.Print();
	}

	//================================================ 
	//Draw line from previous datapoint to this point
	//================================================ 
	//DX, DY : Upper left corner of plot
	//width, height: width and height of plot
	//dataMax, dataMin: Max/Min for plot - y-axis
	//data,time = y, -x
	function plotCoordToWatchCoord(dc, DX, DY, width, height, dataMax, dataMin, data, time){
		var WatchX;
		var WatchY;

		// Compute watch coords for to-point
		if ( (dataMax.toFloat()-dataMin) == 0.0  ){
			//!!!!
			return;
		} else {
			WatchX = DX + width - ((time.toFloat()/_Size.toFloat())*width.toFloat());
			WatchY = DY + height * ((dataMax.toFloat()-data)/(dataMax.toFloat()-dataMin));
		}
//        System.println("DX="+DX+ " DY="+DY+" width="+width+ " height="+height+ " dataMax="+dataMax+" dataMin="+dataMin+ " data="+data+ " time="+time + " _Size=" + _Size);

		if (_PrevWatchX==null){
			_PrevWatchX = WatchX;
			_PrevWatchY = WatchY;
		}
		//Nulstiller forrige koordinat ved første punkt
		if (time==0){
			_PrevWatchX = WatchX;
			_PrevWatchY = WatchY;
		} else if (time<_Size-1){
			dc.drawLine(_PrevWatchX, _PrevWatchY, WatchX, WatchY);
		}

		_PrevWatchX = WatchX;
		_PrevWatchY = WatchY;
	}

}	
