import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
//import Transf;

// ===================================================
// This file contains unit tests for the Transf class
// ===================================================

function doubleCompare(a as Double, b as Double , tolerance) as Boolean {
    // Compare two double values for equality with a tolerance
    //var tolerance = 0.000000000000000001; // Define a tolerance level
    var diff = (a - b);
    if (diff<0.0){
        diff = diff* -1.0d;
    }
    if (diff < tolerance) {
        return true; // Values are considered equal
    }
    return false;
}

function coordCompare(x as Double, xx as Double, y as Double, yy as Double) as Boolean {
    // Compare two double values for equality with a tolerance
    var tolerance = 0.01;
    var bXcomp = doubleCompare(x, xx, tolerance);
    var bYcomp = doubleCompare(y, yy, tolerance);
    if (bXcomp && bYcomp) {
        return true; // Values are considered equal
    }
    return false;
}

(:test)
function utDegRad(logger as Logger) as Boolean {
    var rad = DEG_TO_RAD(45.0); 
    var deg = RAD_TO_DEG(rad); 
    logger.debug("deg = " + deg.format("%.10f"));
    return (doubleCompare(45.0, deg, 0.0000000001)); // returning true indicates pass, false indicates failure
}

(:test)
function utCosh(logger as Logger) as Boolean {
    var param0 = 0.0d as Double;
    var cosh0 = cosh (param0); 
    var bcosh0 = doubleCompare(1.0d, cosh0, 0.0000000000001d);
    logger.debug("cosh(0) = " + cosh0 + " bcosh0 = " + bcosh0);

    var param1 = 1.0d as Double;
    var cosh1 = cosh (param1); 
    var bcosh1 = doubleCompare(1.5430806348152437d, cosh1, 0.0000000000001d);
    logger.debug("cosh(1) = " + cosh1 + " bcosh1 = " + bcosh1);

    var param_2 = -2.0d as Double;
    var cosh_2 = cosh (param_2); 
    var bcosh_2 = doubleCompare(3.76219569108363d, cosh_2, 0.000000000001d);
    logger.debug("cosh(-2) = " + cosh_2 + " bcosh_2 = " + bcosh_2);

    if (bcosh0 && bcosh1 && bcosh_2) {
        return true; // returning true indicates pass
    }

    return false; // returning true indicates pass, false indicates failure
}

(:test)
function utSinh(logger as Logger) as Boolean {
    var sinh0 = sinh (0.0d); 
    var bsinh0 = doubleCompare(0.0d, sinh0, 0.00000000001d);
    logger.debug("sinh(0) = " + sinh0.format("%.15f") + " bsinh0 = " + bsinh0);

    var sinh1 = sinh (1.0d);
    var bsinh1 = doubleCompare(1.1752011936438014d, sinh1, 0.00000000001d);
    logger.debug("sinh(1) = " + sinh1.format("%.15f") + " bsinh1 = " + bsinh1);

    var sinh_2 = sinh (-2.0d);
    var bsinh_2 = doubleCompare(-3.6268604078470186d, sinh_2, 0.00000000001d);
    logger.debug("sinh(-2) = " + sinh_2.format("%.15f") + " bsinh_2 = " + bsinh_2);

    if (bsinh0 && bsinh1 && bsinh_2) {
        return true; // returning true indicates pass
    }
    return false; // returning true indicates pass, false indicates failure
}

(:test)
function utGetLilleHalvakse(logger as Logger) as Boolean {
    var tran = new Transf(); 
    var dLilleHalvakse = tran.GetLilleHalvakse();
    logger.debug("GetLilleHalvakse() = " + dLilleHalvakse.format("%.9f"));
    var tolerance = 0.001d;
    return doubleCompare(6356752.314140347d, dLilleHalvakse, tolerance); // returning true indicates pass, false indicates failure
}

(:test)
function utGetEllipseEks1(logger as Logger) as Boolean {
    var tran = new Transf(); 
    var dEllipseEks1 = tran.GetEllipseEks1();
    logger.debug("GetEllipseEks1() = " + dEllipseEks1.format("%.9f"));
    var tolerance = 0.00000001d;
    return doubleCompare(0.081819191d, dEllipseEks1, tolerance); // returning true indicates pass, false indicates failure
}

(:test)
function utGetMeridianbuelengde(logger as Logger) as Boolean {
    var tran = new Transf(); 
    var dMeridianbuelengde = tran.GetMeridianbuelengde(Math.PI/2.0d);
    logger.debug("GetMeridianbuelengde() = " + dMeridianbuelengde.format("%.4f"));
    var tolerance = 0.5d; // Litt dårlig!
    return doubleCompare(10001965.7292d, dMeridianbuelengde, tolerance); // returning true indicates pass, false indicates failure
}

(:test)
function utGeodetisk2Kartesisk(logger as Logger) as Boolean {
    var dLatDeg= 60.0d; // Bredde
    var dLonDeg= 10.0d; // Lengde
    var dHell = 0.0d;

    var dLatRad = DEG_TO_RAD(dLatDeg); // Bredde i radianer
    var dLonRad = DEG_TO_RAD(dLonDeg); // Lengde i radianer

    var tran = new Transf(); 

    var coord = tran.Geodetisk2Kartesisk(dLatRad, dLonRad, dHell);
    var x = coord["x"]; // actual x coordinate
    var y = coord["y"]; // actual y coordinate
    var z = coord["z"]; // actual z coordinate

    var tolerance = 0.2; // Litt dårlig!
    var xx = 3148533.3844d; // expected x coordinate
    var yy = 555171.3853d; // expected y coordinate
    var zz = 5500477.1338d; // expected z coordinate
    var bXcomp = doubleCompare(x, xx, tolerance);
    var bYcomp = doubleCompare(y, yy, tolerance);
    var bZcomp = doubleCompare(z, zz, tolerance);
    logger.debug("x = " + x.format("%.4f") + " Xdiff=" + (x-xx) + " bXcomp = " + bXcomp.toString());
    logger.debug("y = " + y.format("%.4f") + " Ydiff=" + (y-yy) + " bYcomp = " + bYcomp.toString());
    logger.debug("z = " + z.format("%.4f") + " Zdiff=" + (z-zz) + " bZcomp = " + bZcomp.toString());

    if (bXcomp && bYcomp && bZcomp) {
        return true; // Values are considered equal
    }
    return false;
}

(:test)
function utKartesisk2Geodetisk(logger as Logger) as Boolean {
    var tran = new Transf(); 
    var x = 3148533.3844d; 
    var y = 555171.3853d;  
    var z = 5500477.1338d; 
    var coord = tran.Kartesisk2Geodetisk(x,y,z);
    var B = RAD_TO_DEG(coord["B"]); 
    var L = RAD_TO_DEG(coord["L"]); 
    var h = coord["h"]; 

    var tolerance = 0.00001; // Litt dårlig!
    var BB = 60.0d; 
    var LL = 10.0d; 
    var hh = 0.0d;  
    var bBcomp = doubleCompare(B, BB, tolerance);
    var bLcomp = doubleCompare(L, LL, tolerance);   
    var bhcomp = doubleCompare(h, hh, 0.001d); 

    logger.debug("B = " + B.format("%.10f") + " Bdiff=" + (B-BB).format("%.9f") + " bBcomp = " + bBcomp.toString());
    logger.debug("L = " + L.format("%.10f") + " Ldiff=" + (L-LL).format("%.9f") + " bLcomp = " + bLcomp.toString());
    logger.debug("h = " + h.format("%.4f")  + " hdiff=" + (h-hh).format("%.4f") + " bhcomp = " + bhcomp.toString());

    if (bBcomp && bLcomp && bhcomp) {
        return true; // Values are considered equal
    }

    return false;
}

(:test)
function utGeodetisk2Gausisk_trad(logger as Logger) as Boolean {
    var dLatDeg= 60.0d; // Bredde
    var dLonDeg= 10.0d; // Lengde

    var dLatRad = DEG_TO_RAD(dLatDeg); // Bredde i radianer
    var dLonRad = DEG_TO_RAD(dLonDeg); // Lengde i radianer

    var tran = new Transf(); 

    var coord = tran.Geodetisk2Gausisk_trad(dLatRad,dLonRad);
    logger.debug("b= " + dLatDeg + " l= " + dLonDeg);
    logger.debug("x= " + coord["x"] + " y= " + coord["y"]);

    // UTM
    // E  555776.26675230
    // N 6651832.73531065

    return (false); // returning true indicates pass, false indicates failure
}

(:test)
function utGeodetisk2Gausisk_hyp(logger as Logger) as Boolean {
    var dLatDeg= 60.0d; // Bredde
    var dLonDeg= 10.0d; // Lengde

    var dLatRad = DEG_TO_RAD(dLatDeg); // Bredde i radianer
    var dLonRad = DEG_TO_RAD(dLonDeg); // Lengde i radianer

    var tran = new Transf(); 

    var coord = tran.Geodetisk2Gausisk_hyp(dLatRad,dLonRad);
    logger.debug("b= " + dLatDeg + " l= " + dLonDeg);
    logger.debug("x= " + coord["x"] + " y= " + coord["y"]);

// TESTDATA
// B  60.000
// L  10.000 
// UTM
// E  555776.26675230
// N 6651832.73531065

// results:
// x= 6654494.720887 y= 55798.584905

    return (false); // returning true indicates pass, false indicates failure
}
