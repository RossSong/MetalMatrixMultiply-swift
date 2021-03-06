//
//  MultiplicationData_tests.swift
//
//  Created by Otto Schnurr on 12/29/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import XCTest

class MultiplicationData_tests: XCTestCase {
    
    func test_validDimensions() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, alignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 6, alignment: 8)!
        let output = CPUMatrix(rowCount: 4, columnCount: 6, alignment: 8)!

        let data = TestData(inputA: inputA, inputB: inputB, output: output)
        XCTAssertTrue(data.inputDimensionsAreValid)
        XCTAssertTrue(data.outputDimensionsAreValid)
    }
    
    func test_invalidInputDimensions() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, alignment: 8)!
        let inputB = CPUMatrix(rowCount: 3, columnCount: 6, alignment: 8)!
        let output = CPUMatrix(rowCount: 4, columnCount: 6, alignment: 8)!
        
        let data = TestData(inputA: inputA, inputB: inputB, output: output)
        XCTAssertFalse(data.inputDimensionsAreValid)
        XCTAssertTrue(data.outputDimensionsAreValid)
    }
    
    func test_invalidOutputDimensions() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, alignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 6, alignment: 8)!
        let output = CPUMatrix(rowCount: 5, columnCount: 6, alignment: 8)!
        
        let data = TestData(inputA: inputA, inputB: inputB, output: output)
        XCTAssertTrue(data.inputDimensionsAreValid)
        XCTAssertFalse(data.outputDimensionsAreValid)
    }
    
}


// MARK: - Private
private struct TestData: MultiplicationData {
    
    typealias MatrixType = BufferedMatrix
    
    let inputA: MatrixType
    let inputB: MatrixType
    let output: MatrixType
    
}
