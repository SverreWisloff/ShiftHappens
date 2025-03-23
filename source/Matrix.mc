//import Toybox.System;
import Toybox.Lang;
//import Toybox.Math;

class Matrix 
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
        for (var i = 0; i < rows; i++) {
            var row = [];
            for (var j = 0; j < cols; j++) {
                if (bUnit && i == j) {
                    row.add(1.0);
                } else {
                    row.add(0.0);
                }
            }
            _matrix.add(row);
        }
    }

    public function setValue(i, j, value) as Void {
        if (i >= _rows || j >= _cols) {
            throw new Exception("Index out of bounds");
        }
        _matrix[i][j] = value;
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
                row.add(_matrix[i][j] + MatrixOther._matrix[i][j]);
            }
            result._matrix.add(row);
        }
        return result;
    }

    public function matrixMultiply(MatrixOther) as Matrix {
        if (_cols != MatrixOther.rows()) {
            throw new Exception("Matrix dimensions must be the same");
        }
        var result = new Matrix();
        result.initDimensions(_rows, MatrixOther.cols(), false);
        for (var i = 0; i < _rows; i++) {
            for (var j = 0; j < MatrixOther.cols(); j++) {
                var sum = 0;
                for (var k = 0; k < _cols; k++) {
                    sum += _matrix[i][k] * MatrixOther._matrix[k][j];
                }
                result.setValue(i,j,sum);
            }
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

