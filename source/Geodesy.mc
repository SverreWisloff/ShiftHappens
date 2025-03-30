//using Toybox.Lang;
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