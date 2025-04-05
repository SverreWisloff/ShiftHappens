import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
//import Transf;

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

// Unit test to check if 2 + 2 == 4
(:test)
function myUnitTest(logger as Logger) as Boolean {
    var x = 2 + 2; logger.debug("x = " + x);
    return (x == 4); // returning true indicates pass, false indicates failure
}

(:test)
function utDegRad(logger as Logger) as Boolean {
    var rad = DEG_TO_RAD(90.0); 
    var deg = RAD_TO_DEG(rad); 
    logger.debug("deg = " + deg);
    return (doubleCompare(90.0, deg, 0.000000000001)); // returning true indicates pass, false indicates failure
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
    var bsinh0 = doubleCompare(0.0d, sinh0, 0.0000000000001d);
    logger.debug("sinh(0) = " + sinh0 + " bsinh0 = " + bsinh0);

    var sinh1 = sinh (1.0d);
    var bsinh1 = doubleCompare(1.1752011936438014d, sinh1, 0.0000000000001d);
    logger.debug("sinh(1) = " + sinh1 + " bsinh1 = " + bsinh1);

    var sinh_2 = sinh (-2.0d);
    var bsinh_2 = doubleCompare(-3.6268604078470186d, sinh_2, 0.0000000000001d);
    logger.debug("sinh(-2) = " + sinh_2 + " bsinh_2 = " + bsinh_2);

    if (bsinh0 && bsinh1 && bsinh_2) {
        return true; // returning true indicates pass
    }
    return false; // returning true indicates pass, false indicates failure
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

    // E  555776.26675230
    // N 6651832.73531065

// 6654495.090143501 (Lang.Double)
//   55798.58493023064 (Lang.Double)

    return (coordCompare(coord["x"], 6651832.73531065, coord["y"], 555776.26675230)); // returning true indicates pass, false indicates failure
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

    // E  555776.26675230
    // N 6651832.73531065

// 6654495.090143501 (Lang.Double)
//   55798.58493023064 (Lang.Double)

    return (coordCompare(coord["x"], 6651832.73531065, coord["y"], 555776.26675230)); // returning true indicates pass, false indicates failure
}
