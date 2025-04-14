import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
//import Transf;

// ===================================================
// This file contains unit tests for the Matrix class
// ===================================================

(:test)
function utMtrxInitDimensionsFalse(logger as Logger) as Boolean {
    // Test the initDimensions method of the Matrix class
    var matrix = new Mtrx();
    matrix.initDimensions(3, 4, false); // Initialize a 3x4 matrix
    logger.debug("Matrix.rows() = " + matrix.rows() );
    logger.debug("Matrix.cols() = " + matrix.cols() );
    matrix.print("Mtrx");

    // Check if the matrix has the correct dimensions
    if (matrix.rows() != 3) {
        logger.debug("Expected 3 rows but got " + matrix.rows());
        return false; // Test failed
    }
    if (matrix.cols() != 4) {
        logger.debug("Expected 4 cols but got " + matrix.cols());
        return false; // Test failed
    }

    // Check if all values are initialized to 0.0
    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 4; j++) {
            if (!doubleCompare(matrix.getValue(i, j), 0.0d, 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is 0.0d but got " + matrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }
    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxInitDimensionsTrue(logger as Logger) as Boolean {
    // Test the initDimensions method of the Matrix class
    var matrix = new Mtrx();
    matrix.initDimensions(3, 3, true); // Initialize a 3x4 matrix
    matrix.print("MtrxIDT");
    // Check if the matrix has the correct dimensions
    if (matrix.rows() != 3) {
        logger.debug("Expected 3 rows but got " + matrix.rows());
        return false; // Test failed
    }
    if (matrix.cols() != 3) {
        logger.debug("Expected 3 cols but got " + matrix.cols());
        return false; // Test failed
    }

    // Check if all values are initialized to 0.0
    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
            if (i == j) {
                if (!doubleCompare(matrix.getValue(i, j), 1.0d, 0.000000000000000001)) {
                    logger.debug("Expected value at (" + i + ", " + j + ") is 1.0d but got " + matrix.getValue(i, j).format("%.9f"));
                    return false; // Test failed
                }
            } else {
                if (!doubleCompare(matrix.getValue(i, j), 0.0d, 0.000000000000000001)) {
                    logger.debug("Expected value at (" + i + ", " + j + ") is 0.0d but got " + matrix.getValue(i, j).format("%.9f"));
                    return false; // Test failed
                }
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxSetGetValue(logger as Logger) as Boolean {
    // Test the setValue and getValue methods of the Matrix class
    var matrix = new Mtrx();
    matrix.initDimensions(4, 4, false); // Initialize a 2x4 matrix

    // Set values in the matrix
    matrix.setValue(1, 1, 1.0d); // Set value at (1, 1) to 1.0
    matrix.setValue(2, 3, 3.0d); // Set value at (2, 3) to 3.0

    // Get values from the matrix and compare with expected values
    var value1 = matrix.getValue(1, 1);
    var value2 = matrix.getValue(2, 3);

    if (!doubleCompare(value1, 1.0d, 0.000000000000000001)) {
        logger.debug("Expected value at (1, 1) is 1.0d but got " + value1.format("%.9f"));
        return false; // Test failed
    }
    if (!doubleCompare(value2, 3.0d, 0.000000000000000001)) {
        logger.debug("Expected value at (2, 3) is 3.0d but got " + value2.format("%.9f"));
        return false; // Test failed
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxAddRow(logger as Logger) as Boolean {
        
        var m = new Mtrx();
        m.addRow([5.0d, 6.0d, 7.0d]);
        m.addRow([2.0d, 3.0d, 4.0d]);

        m.print("m.addRow");
        if (m.rows() != 2) {
            logger.debug("Expected 2 rows but got " + m.rows());
            return false; // Test failed
        }
        if (m.cols() != 3) {
            logger.debug("Expected 3 cols but got " + m.cols());
            return false; // Test failed
        }
        if (!doubleCompare(m.getValue(0, 1), 6.0d, 0.000000000000000001)) {
            logger.debug("Expected value at (0, 0) is 5.0d but got " + m.getValue(0, 0).format("%.9f"));
            return false; // Test failed
        }
        return true;
}

(:test)
function utMtrxAddRow2(logger as Logger) as Boolean {
    // Test the addRow method of the Matrix class
    var matrix = new Mtrx();
    matrix.initDimensions(3, 3, true); // Initialize a 2x4 matrix

    // Create a new row to add
    var newRow = [9.0d, 10.0d, 11.0d];

    // Add the new row to the matrix
    matrix.addRow(newRow);

    matrix.print("");

    logger.debug("matrix.getValue(3, 2)=" + matrix.getValue(3, 2).format("%.9f"));

    // Check if the new row was added correctly
    for (var i = 0; i < 3; i++) {
        if (!doubleCompare(matrix.getValue(3, i), newRow[i], 0.000000000000000001)) {
            logger.debug("Expected value at (3, " + i + ") is " + newRow[i].format("%.9f") + " but got " + matrix.getValue(3, i).format("%.9f"));
            return false; // Test failed
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxAdd(logger as Logger) as Boolean {
    // Test the add method of the Matrix class
    var matrix1 = new Mtrx();
    matrix1.initDimensions(2, 2, true);
    matrix1.setValue(0, 0, 1.0d);
    matrix1.setValue(0, 1, 2.0d);
    matrix1.setValue(1, 0, 3.0d);
    matrix1.setValue(1, 1, 4.0d);
    matrix1.print("matrix1");

    var matrix2 = new Mtrx();
    matrix2.initDimensions(2, 2, false);
    matrix2.setValue(0, 0, 5.0d);
    matrix2.setValue(0, 1, 6.0d);
    matrix2.setValue(1, 0, 7.0d);
    matrix2.setValue(1, 1, 8.0d);
    matrix2.print("matrix2");

    var resultMatrix = matrix1.matrixAdd(matrix2);

    resultMatrix.print("resultMatrix");

    // Check if the addition result is correct
    var expectedValues = [
        [6.0d, 8.0d],
        [10.0d, 12.0d]
    ];

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            if (!doubleCompare(resultMatrix.getValue(i, j), expectedValues[i][j], 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is " + expectedValues[i][j].format("%.9f") + " but got " + resultMatrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxSubtract(logger as Logger) as Boolean {
    // Test the subtract method of the Matrix class
    var matrix1 = new Mtrx();
    matrix1.initDimensions(2, 2, true);
    matrix1.setValue(0, 0, 1.0d);
    matrix1.setValue(0, 1, 2.0d);
    matrix1.setValue(1, 0, 3.0d);
    matrix1.setValue(1, 1, 4.0d);
    matrix1.print("matrix1");

    var matrix2 = new Mtrx();
    matrix2.initDimensions(2, 2, false);
    matrix2.setValue(0, 0, 5.0d);
    matrix2.setValue(0, 1, 6.0d);
    matrix2.setValue(1, 0, 7.0d);
    matrix2.setValue(1, 1, 8.0d);
    matrix2.print("matrix2");

    var resultMatrix = matrix1.matrixSubtract(matrix2);

    resultMatrix.print("resultMatrix");

    // Check if the subtraction result is correct
    var expectedValues = [
        [-4.0d, -4.0d],
        [-4.0d, -4.0d]
    ];

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            if (!doubleCompare(resultMatrix.getValue(i, j), expectedValues[i][j], 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is " + expectedValues[i][j].format("%.9f") + " but got " + resultMatrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxMultiply(logger as Logger) as Boolean {
    // Test the multiply method of the Matrix class
    var matrix1 = new Mtrx();
    matrix1.initDimensions(2, 3, true);
    matrix1.setValue(0, 0, 1.0d);
    matrix1.setValue(0, 1, 2.0d);
    matrix1.setValue(0, 2, 3.0d);
    matrix1.setValue(1, 0, 4.0d);
    matrix1.setValue(1, 1, 5.0d);
    matrix1.setValue(1, 2, 6.0d);
    matrix1.print("matrix1");

    var matrix2 = new Mtrx();
    matrix2.initDimensions(3, 2, false);
    matrix2.setValue(0, 0, 7.0d);
    matrix2.setValue(0, 1, 8.0d);
    matrix2.setValue(1, 0, 9.0d);
    matrix2.setValue(1, 1, 10.0d);
    matrix2.setValue(2, 0, 11.0d);
    matrix2.setValue(2, 1, 12.0d);
    matrix2.print("matrix2");

    var resultMatrix = matrix1.matrixMultiply(matrix2);

    resultMatrix.print("resultMatrix");

    // Check if the multiplication result is correct
    var expectedValues = [
        [58.0d, 64.0d],
        [139.0d, 154.0d]
    ];

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            if (!doubleCompare(resultMatrix.getValue(i, j), expectedValues[i][j], 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is " + expectedValues[i][j].format("%.9f") + " but got " + resultMatrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxMultiplyNumber(logger as Logger) as Boolean {
    // Test the multiplyNumber method of the Matrix class
    var matrix = new Mtrx();
    matrix.initDimensions(2, 2, true);
    matrix.setValue(0, 0, 1.0d);
    matrix.setValue(0, 1, 2.0d);
    matrix.setValue(1, 0, 3.0d);
    matrix.setValue(1, 1, 4.0d);
    matrix.print("matrix");

    var scalar = 2.0d;
    matrix.matrixMultiplyNumber(scalar);

    matrix.print("resultMatrix");

    // Check if the multiplication result is correct
    var expectedValues = [
        [2.0d, 4.0d],
        [6.0d, 8.0d]
    ];

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            if (!doubleCompare(matrix.getValue(i, j), expectedValues[i][j], 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is " + expectedValues[i][j].format("%.9f") + " but got " + matrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxTranspose(logger as Logger) as Boolean {
    var matrix1 = new Mtrx();
    matrix1.initDimensions(2, 3, true);
    matrix1.setValue(0, 0, 1.0d);
    matrix1.setValue(0, 1, 2.0d);
    matrix1.setValue(0, 2, 3.0d);
    matrix1.setValue(1, 0, 4.0d);
    matrix1.setValue(1, 1, 5.0d);
    matrix1.setValue(1, 2, 6.0d);
    matrix1.print("matrix1");

    var resultMatrix = matrix1.matrixTranspose();

    resultMatrix.print("resultMatrix");

    // Check if the multiplication result is correct
    var expectedValues = [
        [1.0d, 4.0d],
        [2.0d, 5.0d],
        [3.0d, 6.0d]
    ];

    // Check if the result matrix has the correct dimensions
    if (resultMatrix.rows() != 3 || resultMatrix.cols() != 2) {
        logger.debug("Expected 3 rows and 2 cols but got " + resultMatrix.rows() + " rows and " + resultMatrix.cols() + " cols");
        return false; // Test failed
    }

    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 2; j++) {
            if (!doubleCompare(resultMatrix.getValue(i, j), expectedValues[i][j], 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is " + expectedValues[i][j].format("%.9f") + " but got " + resultMatrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}

(:test)
function utMtrxInverse22(logger as Logger) as Boolean {
    // Test the inverse method of the Matrix class for a 2x2 matrix
    var matrix = new Mtrx();
    matrix.initDimensions(2, 2, true);
    matrix.setValue(0, 0, 4.0d);
    matrix.setValue(0, 1, 7.0d);
    matrix.setValue(1, 0, 2.0d);
    matrix.setValue(1, 1, 6.0d);
    matrix.print("matrix");

    var resultMatrix = matrix.matrixInverse22();

    resultMatrix.print("resultMatrix");

    // Check if the inverse result is correct
    var expectedValues = [
        [0.6d, -0.7d],
        [-0.2d, 0.4d]
    ];

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            if (!doubleCompare(resultMatrix.getValue(i, j), expectedValues[i][j], 0.000000000000000001)) {
                logger.debug("Expected value at (" + i + ", " + j + ") is " + expectedValues[i][j].format("%.9f") + " but got " + resultMatrix.getValue(i, j).format("%.9f"));
                return false; // Test failed
            }
        }
    }

    return true; // returning true indicates pass, false indicates failure
}
