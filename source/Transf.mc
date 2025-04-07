import Toybox.System;
import Toybox.Math;
import Toybox.Lang;

// Diverse transformasjonsformler
// Alle enheter er i meter og radianer

function DEG_TO_RAD(deg as Double) as Double {
    deg = deg.toDouble();
    var result = deg * Math.PI / 180.0;
//    result = result.toDouble();
    return result;
}
function RAD_TO_DEG(rad as Double) as Double { 
    var result = rad / Math.PI * 180.0;
    return result;
}
// Returnerer retning i angitte kvadranter
//   StartKvadrant:  0: omr�det blir   0	-  + 2*PI
//                  -2: omr�det blir -PI	-  +   PI	 
function Kvadrant( r , StartKvadrant )
{
	var rundt = 2.0*Math.PI;

	if ( (StartKvadrant!=(-2)) && (StartKvadrant!=0) )	// -2/0
    {
		return r;
    }
    
	var r1 = r;
	var min = 0.25 * rundt * StartKvadrant;
	var max = min + rundt;

	while ( r1 > max ){
		r1 = r1 - rundt ;
        }
	while ( r1 < min ){
		r1 = r1 + rundt ;
    }
	return ( r1 );
}
function cosh( x as Double) as Double
{
    var c  = 1.0d as Double;
    var f  = 1.0d as Double;
    var xp = 1.0d as Double;

    for (var i = 1; i < 10; i++) // You can increase the number of terms to get better precision
    {
        f *= (2.0 * i - 1.0) * (2.0 * i);
        xp *= x * x;
        c += xp / f;
    }
    return c;
}

// TODO: Check if this is correct !!!!!!!!!!!!!!
function sinh( x )
{
    var s  = x;
    var f  = 1.0;
    var xp = x;

    for (var i = 1; i < 10; i++) // You can increase the number of terms to get better precision
    {
        f *= (2.0 * i) * (2.0 * i + 1.0);
        xp *= x * x;
        s += xp / f;
    }
    return s;
}

class Transf {
    // GRS80 ellipsoid parametre
    private var m_dStoreHalvakse = 6378137.0d as Double;
    private var	m_dFlattrykkning = 1.0d / 298.257222101d as Double;

    // UTM parametre
    private var	m_dSkalafaktor=0.9996d as Double; 
	private var	m_dAddN=0.0d as Double;
	private var	m_dAddE=500000.0d as Double; 

    // UTM 32V
    private var	m_Sentralmeridian=DEG_TO_RAD(9.0) as Double;

    function initialize(){
        // Constructor
        m_dStoreHalvakse = 6378137.0d as Double; // GRS80 ellipsoid parametre
        m_dFlattrykkning = 1.0d / 298.257222101d as Double; // GRS80 ellipsoid parametre

        m_dSkalafaktor=0.9996d as Double; 
        m_dAddN=0.0d as Double;
        m_dAddE=500000.0d as Double; 

        m_Sentralmeridian=DEG_TO_RAD(9.0) as Double; // UTM 32V
    }

    public function GetLilleHalvakse() as Double {
        return( m_dStoreHalvakse * (1.0d - m_dFlattrykkning));
    }

    // Henter f�rste eksentrisitet
    // sqrt( f * ( 2.0 - f ))
    // sqrt( ( a^2 - b^2 ) / a^2 )
    function GetEllipseEks1() as Double
    {
        var dEksentrisitet = Math.sqrt(m_dFlattrykkning * ( 2.0 - m_dFlattrykkning ));
        
        return(dEksentrisitet);
    }

    // Beregner meridianbuelengden fra lang halvakse, flattrykning og breddegrad 
    function GetMeridianbuelengde( dFi as Double ) as Double {
 
        var a  = m_dStoreHalvakse;   // a : lang halvakse
        var f  = m_dFlattrykkning;   // f : flattrykning
        var ff  = f*f;
        var fff = ff*f;
        var b0  = a * ( 1.0 - f/2.0 + ff/16.0 + fff/32.0 );
        var B   =   dFi - ( 0.75*f + 3.0/8.0*ff + 15.0/128.0*fff ) * Math.sin( 2.0*dFi )
            + ( 15.0/64.0*ff + 15.0/64.0*fff ) * Math.sin( 4.0*dFi )
            - ( 35.0/384.0*fff ) * Math.sin( 6.0*dFi );
        B   = b0*B;

        return B;
    }

    // Beregner normalkrumningsradius fra lang halvakse, flattrykning og breddegrad 
    function GetNormalKrRad( dFi as Double ) as Double {
        var w = GetEn_Minus_sqr_e_sinfi( dFi );
        var a = m_dStoreHalvakse;
        var N = a / Math.sqrt( w );

        return N;
    }

    // Beregner uttrykket  1 - sqr( e*sin(fi) ). 
    // Brukes av GetNormalKrRad og GetMeridianKrRad()
    function GetEn_Minus_sqr_e_sinfi( dFi as Double ) as Double
    {
        var dRetur = 1.0 - Math.pow( GetEllipseEks1()*Math.sin(dFi), 2.0 );
    
        return( dRetur );
    }    

    // Beregner uttrykket N/M-1 = e^2/(1-e*e) * (cos(fi))^2
    // Dette beneves som epsilon i annen
    function GetEpsilon_2( dFi as Double ) as Double
    {
        var e = GetEllipseEks1();
        var ee   = e*e;
        var Eps2 = ee / ( 1.0-ee ) * Math.pow( Math.cos(dFi) , 2.0 );

        return( Eps2 );
    }

    function Geodetisk2Kartesisk( dB as Double, dL as Double, dHEll as Double ) as Double {
        var a  = m_dStoreHalvakse;   // a : lang halvakse
        var f  = m_dFlattrykkning;   // f : flattrykning

        var b  = a - a*f;
        var N  = GetNormalKrRad( dB );
        var p  = ( N + dHEll ) * Math.cos( dB );
        
        var dX = p * Math.cos( dL );
        var dY = p * Math.sin( dL );
        var dZ = ( Math.pow( b/a, 2 ) * N + dHEll ) * Math.sin( dB );

        return { "x" => dX, "y" => dY, "z" => dZ };
    }

    function Kartesisk2Geodetisk( dX as Double, dY as Double, dZ as Double ) as Double {
        var a    = m_dStoreHalvakse;   // a : lang halvakse
        var f    = m_dFlattrykkning;   // f : flattrykning
	    var b    = a - a*f;
	    var e2   = Math.pow( GetEllipseEks1(), 2 );
	    var e__2 = Math.pow( a/b, 2 ) - 1.0d;
	    var p    = Math.sqrt( ( dX*dX ) + ( dY*dY ) );
	    var t    = Math.atan2( dZ*a, p*b );
	    var c3t  = Math.pow( Math.cos( t ), 3 );
	    var s3t  = Math.pow( Math.sin( t ), 3 );
	    var dB   = Math.atan2( dZ + e__2*b*s3t , p - e2*a*c3t );
	    var dL   = Math.atan2( dY, dX );
	    var N    = GetNormalKrRad( dB );
	    var dHEll = p/Math.cos( dB ) - N;
        return { "B" => dB, "L" => dL, "h" => dHEll };
    }


    // Fra geografiske koordinater til gaussiske
    // HYPERBOLIC FUNCTION FOR THE GAUSSIAN PROJECTION 
    function Geodetisk2Gausisk_hyp( dB as Double, dL as Double ) as Double {
        var a  = m_dStoreHalvakse;   // a : lang halvakse
        var f  = m_dFlattrykkning;   // f : flattrykning
        var l0 = m_Sentralmeridian; // l0: tangeringsmeridian
        var e  = Math.sqrt(f*(2.0d-f));	                    // Eccentricity
        
        var df2 = f*f;  // pow(f,2)
        var df3 = df2*f;// pow(f,3)

        dL = Kvadrant( dL-l0, -2 );          // dL : lengdeforskjell
        
        var b0 = a * ( 1.0d - f/2.0d + df2/16.0d + df3/32.0d );
        var b1 = a * ( f/4.0d - df2/6.0d - df3*11.0d/384.0d );
        var b2 = a * ( df2*13.0d/192.0d - df3*79.0d/1920.0d );
        var b3 = a * ( df3*61.0d/1920.0d );
        
        var sB = Math.sin(dB);
        var sL = Math.sin(dL);
        var w = (Math.atan( Math.tan(dB/2.0d + Math.PI/4.0d)*Math.pow((1.0-e*sB)/(1.0d+e*sB),e/2.0d)) - Math.PI/4.0d)*2.0d;
	
        var u = Math.atan2(Math.tan(w),Math.cos(dL));
        var cw = Math.cos(w);
        var v = Math.ln( (1.0d+cw*sL)/(1.0d-cw*sL) )/2.0d;
        
        var d2u = 2.0d*u;
        var d2v = 2.0d*v;
        var d4u = 4.0d*u;
        var d4v = 4.0d*v;
        var d6u = 6.0d*u;
        var d6v = 6.0d*v;
        
        var dX = b0*u + b1*Math.sin(d2u)*Math.cosh(d2v) + b2*Math.sin(d4u)*Math.cosh(d4v) + b3*Math.sin(d6u)*Math.cosh(d6v);
        var dY = b0*v + b1*Math.cos(d2u)*Math.sinh(d2v) + b2*Math.cos(d4u)*Math.sinh(d4v) + b3*Math.cos(d6u)*Math.sinh(d6v);

        return { "x" => dX, "y" => dY };
    }

    // Fra geografiske koordinater til gaussiske
    function Geodetisk2Gausisk_trad( dB as Double, dL as Double ) as Double {
        var l0 = m_Sentralmeridian; // l0: tangeringsmeridian
        var l    = Kvadrant( dL-l0, -2 );               // l : lengdeforskjell
        var ll   = l*l;
        var lll  = ll*l;
        var B    = GetMeridianbuelengde( dB );// B : Meridianbuelengde
        var N    = GetNormalKrRad( dB );
        var sfi  = Math.sin( dB );
        var cfi  = Math.cos( dB );
        var c3fi = cfi * cfi * cfi;
        var c5fi = c3fi * cfi * cfi;
        var t2fi = Math.pow( Math.tan(dB), 2 );
        var t4fi = Math.pow( t2fi, 2 );
        var Eps2 = GetEpsilon_2( dB );
        
        var dX =   B + ll/2.0d * N*sfi*cfi
            + ll*ll/24.0d * N*sfi*c3fi * ( 5.0d - t2fi + 9.0d*Eps2 + 4.0d*Math.pow( Eps2, 2 ) )
            + lll*lll/720.0d * N*sfi*c5fi * ( 61.0d - 58.0d*t2fi + t4fi );
        
        var dY =   l*N*cfi
            + lll/6.0d * N*c3fi * ( 1.0d - t2fi + Eps2 )
            + lll*ll/120.0d * N*c5fi * ( 5.0d - 18.0d*t2fi + t4fi );
        
        return { "x" => dX, "y" => dY };
    }

    function Gausisk2Geodetisk( dX, dY){
/*
	int Err=0;
	double dB, dL;
	CVGDatum *pDatum;
	
	assert(pProjeksjon->SjekkProjeksjon()); // Har du husket � defnere projeksjon f�r du bruker det?
	
	Err = Gausisk2Geodetisk( dN, dE, pProjeksjon, &dB, &dL );
	pDatum = pProjeksjon;
	Geodetisk2Kartesisk( dB, dL, dHEll, pDatum, pdX, pdY, pdZ );

*/
    }

    function Gausisk2TransMercator( dXg, dYg){
        var N = dXg * m_dSkalafaktor  +  m_dAddN;                      // M�lestokk p� sentralmer og Translasjon
        var E = dYg * m_dSkalafaktor  +  m_dAddE;
        
        //if(dFi!=0.0){
        //    Roter2D( N, E, dFi, &N, &E );      // Rotasjon
        //}
        
        //if ( pProjeksjon->GetRetning1Akse() == 2 )  N = -N;   // Snur akser
        //if ( pProjeksjon->GetRetning2Akse() == 2 )  E = -E;
        
        var dXutm = N;
        var dYutm = E;
  
        return { "N" => dXutm, "E" => dYutm };
    }

    function TransMercator2Gausisk( dXutm, dYutm){
/*
	int     Err=0, nVGLKoorSys=1;
	double  k, N0, E0, N, E, dFi;
	
	assert(pProjeksjon->SjekkProjeksjon());         // Har du husket � defnere projeksjon f�r du bruker det?
	
	k  = pProjeksjon->GetSkalafaktor();
	N0 = pProjeksjon->GetAddN();
	E0 = pProjeksjon->GetAddE();
	dFi= pProjeksjon->GetRotasj();                  // i radianer
	
	if ( pProjeksjon->GetRetning1Akse() == 2 )  dXutm = -dXutm;  // Snur akser
	if ( pProjeksjon->GetRetning2Akse() == 2 )  dYutm = -dYutm;
	
	if(dFi!=0.0)
	{
		Err = Roter2D( dXutm, dYutm, -dFi, &N, &E );    // Rotasjon
		if ( Err != 0 )  return( Err );
	}
	else
	{
		N = dXutm;
		E = dYutm;
	}
	
	*pdXg = ( N-N0 ) / k;                            // M�lestokk p� sentralmer og Translasjon
	*pdYg = ( E-E0 ) / k;


*/
    }
}