//import Toybox.System;
import Toybox.Lang;
//import Toybox.Math;

// Matrix:
// [ 1  2  3  4 
//   5  6  7  8]
// cols=4, rows=2
// Array representation:
// [ 1  2  3  4  5  6  7  8]
// col=3, row=2 => value=7
// matrix[4*(2-1)+3] = 7
// matrix[cols*(row-1)+col] = value

// Matrix2: storing multidimensional arrays in linear storage (row-major order)


// TODO: https://en.wikipedia.org/wiki/Row-_and_column-major_order


class Matrix2 
{
    private var _rows as Number;
    private var _cols as Number;
    private var _matrix;

    public function initialize() {
        _rows = 0;
        _cols = 0;
        _matrix = [];
    }

    public function rows() as Number {
        return _rows;
    }

    public function cols() as Number {
        return _cols;
    }

    public function initDimensions(rows as Number, cols as Number, bUnit as Boolean) as Void{
        _rows = rows;
        _cols = cols;
        for (var i = 0; i < rows*cols; i++) {
            _matrix.add(0.0d);
            //TODO: check if bUnit is true and set the diagonal to 1.0d
        }
    }

    public function setValue(i, j, value as Double) as Void {
        if (i >= _rows || j >= _cols) {
            throw new Exception("Index out of bounds");
        }
        //_matrix[_cols*(row-1)+col] = value;
    }
    public function getValue(i, j) as Double {
        if (i >= _rows || j >= _cols) {
            throw new Exception("Index out of bounds");
        }
        return _matrix[i][j];
    }

    public function addRow(row) as Void {
        if (_cols>0 && row.size() != _cols) {
            throw new Exception("Row has wrong length");
        }
        _matrix.add(row);
        _rows++;
        _cols = row.size();
    }

    public function matrixAdd(MatrixOther) as Matrix {
        if (_rows != MatrixOther.rows() || _cols != MatrixOther.cols()) {
            throw new Exception("Matrix dimensions must be the same");
        }
        var result = new Matrix();
        for (var i = 0; i < _rows; i++) {
            var row = [];
            for (var j = 0; j < _cols; j++) {
                row.add(_matrix[i][j] + MatrixOther.getValue(i,j));
            }
            result.addRow(row);
        }
        return result;
    }

    public function matrixSubtract(MatrixOther) as Matrix {
        if (_rows != MatrixOther.rows() || _cols != MatrixOther.cols()) {
            throw new Exception("Matrix dimensions must be the same");
        }
        var result = new Matrix();
        for (var i = 0; i < _rows; i++) {
            var row = [];
            for (var j = 0; j < _cols; j++) {
                row.add(_matrix[i][j] - MatrixOther.getValue(i,j));
            }
            result.addRow(row);
        }
        return result;
    }

    public function matrixMultiply(MatrixOther) as Matrix {
        if (_cols != MatrixOther.rows()) {
            throw new Exception("Matrix dimensions must be the same");
        }
        var result = new Matrix();
        for (var i = 0; i < self.rows(); i++) {
            var row = [];
            for (var j = 0; j < MatrixOther.cols(); j++) {
                var sum = 0;
                for (var k = 0; k < MatrixOther.rows(); k++) {
                    sum += _matrix[i][k] * MatrixOther.getValue(k,j);
                }
                row.add(sum);
            }
            result.addRow(row);
        }        
        return result;
    }

    public function matrixMultiplyNumber(Number) as Void {
        for (var i = 0; i < _rows; i++) {
            for (var j = 0; j < _cols; j++) {
                var newValue = _matrix[i][j] * Number;
                self.setValue(i,j,newValue);
            }
        }
    }

    public function matrixTranspose() as Matrix {
        var result = new Matrix();
        for (var i = 0; i < _cols; i++) {
            var row = [];
            for (var j = 0; j < _rows; j++) {
                row.add(_matrix[j][i]);
            }
            result.addRow(row);
        }
        return result;
    }

    public function matrixInverse22() as Matrix {
        if (_rows != 2 || _cols != 2) {
            throw new Exception("Matrix must be square 2x2");
        }

        var result = new Matrix();
        result.initDimensions(_rows, _cols, true);

        // Assuming a is a 2x2 matrix for simplicity. Implementing general matrix inversion is complex.
        var det = _matrix[0][0] * _matrix[1][1] - _matrix[0][1] * _matrix[1][0];

        result.setValue(0,0, _matrix[1][1] / det);
        result.setValue(1,0,-_matrix[0][1] / det);
        result.setValue(0,1,-_matrix[1][0] / det);
        result.setValue(1,1, _matrix[0][0] / det);

        return result;
    }

    //TODO: Implement toString
    public function toString()  as String {
        return "Matrix";
    }

    public function print(name as String) as Void {
        for (var i = 0; i < _rows; i++) {
            var strRow;
            if (i==0){
                strRow = name + " = [ [";
            }
            else {
                strRow = "      [";
            }
            for (var j = 0; j < _cols; j++) {
                strRow += _matrix[i][j] + " ";
            }
            if (i < _rows-1) {
                strRow += " ]";
            }
            else {
                strRow += " ] ]";
            }
            System.println(strRow);
        }
    }
}

