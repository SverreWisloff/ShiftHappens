using Toybox.System;
using Toybox.WatchUi;

class KalmanFilter {
        var A;  // Tilstandstransisjonsmatrise: Brukes til å forutsi neste tilstand basert på nåværende posisjon og hastighet.
        var B;  // Kontrollmatrise: Brukes til å forutsi neste tilstand basert på akselerasjon u_x, u_y.
        var H;  // Målingsmatrise: Brukes til å konvertere tilstand til måling.
        var Q;  // Prosessstøykovarians: Usikkerhet i prosessen (akselerasjon).
        var R;  // Målingsstøykovarians: Usikkerhet i målingene (posisjon).
        var P;
        var I;
        var x;  // Tilstandsvektor: x=[x,y, v_x,v_y], x,y = Posisjon, v_x,v_y = Hastighet 
        var u;  // Akselerasjon: u=[u_x, u_y]
        public var _bInitPosSet=false;
        private var _lat0;
        private var _lon0;

    function getVelocityKnot() {
        var knot = Math.sqrt(Math.pow(x.getValue(2,0),2) + Math.pow(x.getValue(3,0),2)) * 1.94384;

        return knot;
    }

    function getHeadingDeg() {
        var heading = Math.atan2(x.getValue(2,0), x.getValue(3,0)) * 180.0 / Math.PI;
        if (heading < 0) {
            heading += 360.0;
        }
        return heading;
    }

    function initialize(dt, u_x, u_y, std_acc, x_std_meas, y_std_meas) {
        _bInitPosSet=false;
        _lat0 = 0.0;
        _lon0 = 0.0;
        // Define the 2x2 Identity matrix
//        I = [[1, 0], 
//             [0, 1]];

        // Define the initial state-vector (position and velocity)
        x = new Matrix();
//        x.addRow([0.0, 0.0, 0.0, 0.0]);
        x.addRow([0.0]);
        x.addRow([0.0]);
        x.addRow([0.0]);
        x.addRow([0.0]);
//        x.print("x");

        // Define the state transition matrix A
        //[ [1  0 dt  0  ]
        //  [0  1  0 dt  ]
        //  [0  0  1  0  ]
        //  [0  0  0  1  ] ]        
        A = new Matrix();
        A.initDimensions(4,4,true);
        A.setValue(0,2, dt);
        A.setValue(1,3, dt);
//        A.print("A");

        // Define the control input matrix B
        B = new Matrix();
        B.addRow([Math.pow(dt,2)/2.0,                0.0]);
        B.addRow([               0.0, Math.pow(dt,2)/2.0]);
        B.addRow([                dt,                0.0]);
        B.addRow([               0.0,                 dt]);
//        B.print("B");

        // Define the measurement mapping matrix
        //  H = [ [1.0, 0.0, 0.0, 0.0],
        //        [0.0, 1.0, 0.0, 0.0] ];
        H = new Matrix();
        H.initDimensions(2,4,true);
//        H.print("H");

        // Initial Process Noise Covariance
        Q = new Matrix();
        Q.addRow([Math.pow(dt,4)/4.0,                0.0, Math.pow(dt,3)/2.0,                0.0]);
        Q.addRow([               0.0, Math.pow(dt,4)/4.0,                  0, Math.pow(dt,3)/2.0]);
        Q.addRow([Math.pow(dt,3)/2.0,                0.0,     Math.pow(dt,2),                0.0]);
        Q.addRow([               0.0, Math.pow(dt,3)/2.0,                0.0,     Math.pow(dt,2)]);
//        Q.print("Q");

        Q.matrixMultiplyNumber(Math.pow(std_acc,2));
//        Q.print("Q");

        // Initial Measurement Noise Covariance
        R = new Matrix();
        R.addRow([Math.pow(x_std_meas,2),                    0.0]);
        R.addRow([                   0.0, Math.pow(y_std_meas,2)]);
//        R.print("R");

        // Initial Covariance Matrix
        //  P = [[1.0, 0.0, 0.0, 0.0],
        //      [0.0, 1.0, 0.0, 0.0],
        //      [0.0, 0.0, 1.0, 0.0],
        //      [0.0, 0.0, 0.0, 1.0]];
        P = new Matrix();
        P.initDimensions(4,4,true);
//        P.print("P");
        // Set the acceleration-vector
        u = new Matrix();
        u.addRow([u_x]);
        u.addRow([u_y]);
//        u.print("u");
    }

    function setInitPos(lat, lon) {
        //var coord = latLonToWebMercator(lat, lon);
        var lat0 = 0.0; // Reference latitude
        var lon0 = 0.0; // Reference longitude
        
        lat0 = (Math.round(lat / 1000.0) * 1000.0) - 1000.0;
        lon0 = (Math.round(lon / 1000.0) * 1000.0) - 1000.0;
        
        var coord = latLonToEquirectangular(lat, lon, lat0, lon0);
        x.setValue(0,0, coord["x"]);
        x.setValue(1,0, coord["y"]);
        _bInitPosSet = true;

    }


    // estimerer neste posisjon
    function predict() {
        // Beregner ny tilstandsestimat basert på forrige tilstandsestimat og akselerasjon
        // x = matrixAdd(matrixMultiply(A, x), matrixMultiply(B, u));
        var Ax = new Matrix();
        Ax = A.matrixMultiply(x);
//        Ax.print("Ax");

        var Bu = new Matrix();
        Bu = B.matrixMultiply(u);
//        Bu.print("Bu");

        x = Ax.matrixAdd(Bu);
//        x.print("x");

        // Oppdaterer kovariansmatrisen
        // P = matrixAdd(matrixMultiply(matrixMultiply(A, P), matrixTranspose(A)), Q);
        var AP = new Matrix();
        AP = A.matrixMultiply(P);
//        AP.print("AP");

        var At = A.matrixTranspose();
//        At.print("At");

        var APAt = new Matrix();
        APAt = AP.matrixMultiply(At);
//        APAt.print("APAt");

        P = APAt.matrixAdd(Q);
//        P.print("P");

        return [x.getValue(0,0), x.getValue(1,0)];
    }

    // oppdaterer posisjonen basert på måling
    function update(zx, zy) {
        // S = HPH' + R
        //var S = matrixAdd(matrixMultiply(matrixMultiply(H, P), matrixTranspose(H)), R);
        var z = new Matrix();
        z.addRow([zx]);
        z.addRow([zy]);
//        z.print("z");

        var HP = new Matrix();
        HP = H.matrixMultiply(P);
//        HP.print("HP");

        var Ht = H.matrixTranspose();
//        Ht.print("Ht");

        var HPHt = new Matrix();
        HPHt = HP.matrixMultiply(Ht);
//        HPHt.print("HPHt");

        var S = HPHt.matrixAdd(R);
//        S.print("S");

        // Calculate the Kalman Gain
        //var K = matrixMultiply(matrixMultiply(P, matrixTranspose(H)), matrixInverse(S));
        var PHt = new Matrix();       
        PHt = P.matrixMultiply(Ht);
//        PHt.print("PHt");

        var Sinv = S.matrixInverse22();
//        Sinv.print("Sinv");

        var K = PHt.matrixMultiply(Sinv);
//        K.print("K");

        // Update the estimate via z
        //x = matrixAdd(x, matrixMultiply(K, matrixSubtract(z, matrixMultiply(H, x))));
        var Hx = H.matrixMultiply(x);
//        Hx.print("Hx");

        var zHx = z.matrixSubtract(Hx);
//        zHx.print("zHx");

        var KzHx = K.matrixMultiply(zHx);
//        KzHx.print("KzHx");

        x = x.matrixAdd(KzHx);
//        x.print("x");

        // Update the error covariance
        //P = matrixMultiply(matrixSubtract(I, matrixMultiply(K, H)), P);
        var KH = K.matrixMultiply(H);
//        KH.print("KH");

        var I = new Matrix();
        I.initDimensions(4,4,true);

        var IKH = I.matrixSubtract(KH);
//        IKH.print("IKH");

        P = IKH.matrixMultiply(P);
//        P.print("P");

        return [x.getValue(0,0), x.getValue(1,0)];
    }
}
/*
    function matrixMultiplyNumber(a, multiplier) {
        var result = [];
        for (var i = 0; i < a.size(); i++) {
            var row = [];
            for (var j = 0; j < a[i].size(); j++) {
                var newNumber = a[i][j] * multiplier;
                row.add(newNumber);
            }
            result.add(row);
        }
        return result;
    }

    function matrixMultiply(a, b) {
        var result = [];
        for (var i = 0; i < a.size(); i++) {
            var row = [];
            for (var j = 0; j < b[0].size(); j++) {
                var sum = 0;
                for (var k = 0; k < b.size(); k++) {
                    sum += a[i][k] * b[k][j];
                }
                row.add(sum);
            }
            result.add(row);
        }
        return result;
    }

    function matrixAdd(a, b) {
        var result = [];
        for (var i = 0; i < a.size(); i++) {
            var row = [];
            for (var j = 0; j < a[0].size(); j++) {
                row.add(a[i][j] + b[i][j]);
            }
            result.add(row);
        }
        return result;
    }

    function matrixSubtract(a, b) {
        var result = [];
        for (var i = 0; i < a.size(); i++) {
            var row = [];
            for (var j = 0; j < a[0].size(); j++) {
                row.add(a[i][j] - b[i][j]);
            }
            result.add(row);
        }
        return result;
    }

    function matrixTranspose(a) {
        var result = [];
        for (var i = 0; i < a[0].size(); i++) {
            var row = [];
            for (var j = 0; j < a.size(); j++) {
                row.add(a[j][i]);
            }
            result.add(row);
        }
        return result;
    }

    function matrixInverse(a) {
        // Assuming a is a 2x2 matrix for simplicity. Implementing general matrix inversion is complex.
        var det = a[0][0] * a[1][1] - a[0][1] * a[1][0];
        return [
            [a[1][1] / det, -a[0][1] / det],
            [-a[1][0] / det, a[0][0] / det]
        ];
    }
}

// Example usage:
var dt = 1;  // Time step
var u_x = 0;  // Acceleration in x-direction
var u_y = 0;  // Acceleration in y-direction
var std_acc = 0.1;  // Process noise magnitude
var x_std_meas = 0.5;  // Measurement noise standard deviation in x-direction
var y_std_meas = 0.5;  // Measurement noise standard deviation in y-direction

var kf = new KalmanFilter();
kf.initialize(dt, u_x, u_y, std_acc, x_std_meas, y_std_meas);
kf.setAcceleration(0.1, 0.1);

// Simulate some measurements
var measurements = [
    [1, 1], [2, 2], [3, 3], [4, 4], [5, 5]
];

for (var i = 0; i < measurements.size(); i++) {
    var measurement = measurements[i];
    var predicted = kf.predict();
    var updated = kf.update(measurement);
    System.println("Predicted: " + predicted + ", Updated: " + updated);
}

*/