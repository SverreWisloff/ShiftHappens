using Toybox.System;
using Toybox.Math;

//transform latitude and longitude to Cartesian coordinates using the Equirectangular Projection
// Use: 
//    var coord = latLonToEquirectangular(lat, lon, lat0, lon0);
//    System.println("Projected Coordinates:");
//    System.println("X: " + coord["x"]);
//    System.println("Y: " + coord["y"]);
function latLonToEquirectangular(lat, lon, lat0, lon0) {
    // lat, lon: Latitude and Longitude of the point to project
    // lat0, lon0: Latitude and Longitude of the origin (reference point)
    
    var R = 6378137.0; // Earth's radius in meters (mean radius)
    var x = R * (lon - lon0) * Math.cos(lat0 * Math.PI / 180.0);
    var y = R * (lat - lat0) * Math.PI / 180.0;
    
    return { "x" => x, "y" => y };
}

// transform latitude and longitude to Web Mercator (EPSG:3857) x and y coordinates
// Use: 
//    var coord = latLonToWebMercator(lat, lon);
//    System.println("Projected Coordinates:");
//    System.println("X: " + coord["x"]);
//    System.println("Y: " + coord["y"]);
function latLonToWebMercator(lat, lon) {
    // lat, lon: Latitude and Longitude of the point to project

    var R = 6378137.0; // Earth's radius in meters (WGS84)
    var x = R * lon / (180.0/Math.PI); // Convert longitude to radians and scale
    var y = R * Math.ln(Math.tan((Math.PI / 4.0) + (lat * Math.PI / 360.0))); // Convert latitude to radians and scale
    
    return { "x" => x, "y" => y };
}
/*
function DEG_TO_RAD(deg){
    var result = (deg) * Math.PI / 180.0;
    return result;
}
function RAD_TO_DEG(rad){
    var result = rad / Math.PI * 180.0;
    return result;
}
*/
function latLonToTM(lat, lon, lon0, k0) {
    // k0 : Scale factor, UTM is usually 0.9996
    var WGS84_A = 6378137.0; // Semi-major axis of the WGS84 ellipsoid
    var WGS84_F = 1.0/298.257223563; // Flattening
//    var WGS84_E = sqrt(WGS84_E2); // Eccentricity of the WGS84 ellipsoid
//    var WGS84_E1 = sqrt(WGS84_E2 / (1 - WGS84_E2)); // First eccentricity of the WGS84 ellipsoid
    var WGS84_E2 = (2.0*WGS84_F - WGS84_F*WGS84_F); // Square of eccentricity of the WGS84 ellipsoid



    var a = WGS84_A;
    var e2 = WGS84_E2;
    var e4 = e2 * e2;
    var e6 = e4 * e2;
//    var N, T, C, A, M;
    
    lat = DEG_TO_RAD(lat);
    lon = DEG_TO_RAD(lon);
    lon0 = DEG_TO_RAD(lon0);
    
    var n = a / Math.sqrt(1.0 - e2 * Math.sin(lat) * Math.sin(lat));
    var t = Math.tan(lat) * Math.tan(lat);
    var c = e2 / (1.0 - e2) * Math.cos(lat) * Math.cos(lat);
    var a_ = (lon - lon0) * Math.cos(lat);
    
    var M = a * ((1.0 - e2 / 4.0 - 3.0 * e4 / 64.0 - 5.0 * e6 / 256.0) * lat 
             - (3.0 * e2 / 8.0 + 3.0 * e4 / 32.0 + 45.0 * e6 / 1024.0) * Math.sin(2.0 * lat) 
             + (15.0 * e4 / 256.0 + 45.0 * e6 / 1024.0) * Math.sin(4.0 * lat) 
             - (35.0 * e6 / 3072.0) * Math.sin(6.0 * lat));
    
    var x = k0 * n * (a_ + (1.0 - t + c) * Math.pow(a_, 3.0) / 6.0 + (5.0 - 18.0 * t + t * t + 72.0 * c - 58.0 * e2) * Math.pow(a_, 5) / 120.0);
    var y = k0 * (M + n * Math.tan(lat) * (Math.pow(a_, 2) / 2.0 + (5.0 - t + 9.0 * c + 4.0 * c * c) * Math.pow(a_, 4.0) / 24.0 
                                   + (61.0 - 58.0 * t + t * t + 600.0 * c - 330.0 * e2) * Math.pow(a_, 6) / 720.0));

    System.println("lat: " + RAD_TO_DEG(lat) + " lon: " + RAD_TO_DEG(lon) + " x: " + x + " y: " + y);


    return { "x" => x, "y" => y };
}
