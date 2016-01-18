//
//  MetalPipeline_tests.swift
//
//  Created by Otto Schnurr on 12/30/15.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//

import XCTest

class MetalPipeline_tests: XCTestCase {

    var pipeline: MetalPipeline!
    
    override func setUp() {
        super.setUp()
        if let device = _metalDeviceForPipelineTesting {
            pipeline = MetalPipeline(device: device, countAlignment: 8)
        }
    }
    
    override func tearDown() {
        pipeline = nil
        super.tearDown()
    }
    
    func test_pipeline_isAvailable() {
        XCTAssertFalse(pipeline == nil)
    }

    func test_pipelineWithBadAlignment_cannnotBeCreated() {
        let device = _metalDeviceForPipelineTesting!
        let pipeline = MetalPipeline(device: device, countAlignment: 0)
        XCTAssertTrue(pipeline == nil)
    }

    func test_pipeline_vendsValidMatrix() {
        let matrix = pipeline.newMatrixWithRowCount(4, columnCount: 4)
        XCTAssertFalse(matrix == nil)
    }
    
    func test_pipeline_doesNotVendInvalidMatrix() {
        let matrix = pipeline.newMatrixWithRowCount(0, columnCount: 4)
        XCTAssertTrue(matrix == nil)
    }
    
    func test_invalidMatrices_failToMultiply() {
        let inputA = pipeline.newMatrixWithRowCount(2, columnCount: 4)!
        let inputB = pipeline.newMatrixWithRowCount(2, columnCount: 6)!
        let output = pipeline.newMatrixWithRowCount(5, columnCount: 6)!
        let badData = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try pipeline.multiplyData(badData)
            XCTFail("Multiplied matrices with bad output dimensions.")
        } catch PipelineError.InvalidOutputDimensions {
        } catch {
            XCTFail("Failed to report bad output dimensions.")
        }
    }
    
    func test_invalidRepeatCount_failsToMultiply() {
        let inputA = pipeline.newMatrixWithRowCount(2, columnCount: 4)!
        let inputB = pipeline.newMatrixWithRowCount(2, columnCount: 6)!
        let output = pipeline.newMatrixWithRowCount(4, columnCount: 6)!
        let data = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try pipeline.multiplyData(data, repeatCount: -1)
            XCTFail("Multiplied matrices with bad repeat count.")
        } catch PipelineError.InvalidRepeatCount {
        } catch {
            XCTFail("Failed to report bad repeat count.")
        }
    }
    
    func test_incompatibleDevice_failsToMultiply() {
        let defaultDevice = MTLCreateSystemDefaultDevice()!
        let canCreateIncompatibleDevice =
            unsafeAddressOf(defaultDevice) != unsafeAddressOf(pipeline.device)
        guard canCreateIncompatibleDevice else { return }
        
        let inputA = MetalMatrix(rowCount: 2, columnCount: 4, countAlignment: 8, device: defaultDevice)!
        let inputB = MetalMatrix(rowCount: 2, columnCount: 6, countAlignment: 8, device: defaultDevice)!
        let output = MetalMatrix(rowCount: 4, columnCount: 6, countAlignment: 8, device: defaultDevice)!
        let data = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try pipeline.multiplyData(data)
            XCTFail("Multiplied matrices with incompatible device.")
        } catch PipelineError.IncompatibleDevice {
        } catch {
            XCTFail("Failed to report incompatible device.")
        }
    }
    
    func test_successfulMultiplication_hasExpectedOutput() {
        let inputA = pipeline.newMatrixWithRowCount(2, columnCount: 2)!
        let inputB = pipeline.newMatrixWithRowCount(2, columnCount: 2)!
        let output = pipeline.newMatrixWithRowCount(2, columnCount: 2)!
        let data = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        let firstRowA = inputA.baseAddress
        let secondRowA = inputA.baseAddress + inputA.paddedColumnCount
        firstRowA[0] = 1.0
        firstRowA[1] = 2.0
        secondRowA[0] = 3.0
        secondRowA[1] = 4.0
        
        let firstRowB = inputB.baseAddress
        let secondRowB = inputB.baseAddress + inputB.paddedColumnCount
        firstRowB[0] = 5.0
        firstRowB[1] = 6.0
        secondRowB[0] = 7.0
        secondRowB[1] = 8.0

        do {
            try pipeline.multiplyData(data)

            let epsilon = MatrixElement(0.000001)
            let firstRow = output.baseAddress
            let secondRow = output.baseAddress + output.paddedColumnCount

            XCTAssertEqualWithAccuracy(firstRow[0], 26.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(firstRow[1], 30.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[0], 38.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[1], 44.0, accuracy: epsilon)
        } catch {
            XCTFail("Failed to multiply matrices.")
        }
    }

}


// MARK: - Private

// critical: Creating a Metal pipeline more than once with a discrete GPU
//           appears to cause a kernel panic on OSX. Using the integrated
//           device for testing when available.
private var _metalDeviceForPipelineTesting: MTLDevice? = {
#if os(OSX)
    if let device = MTLCopyAllDevices().filter({ $0.lowPower }).first {
        return device
    }
#endif

    return MTLCreateSystemDefaultDevice()
}()

private struct MetalData: MultiplicationData {
    
    typealias MatrixType = MetalMatrix
    
    let inputA: MatrixType
    let inputB: MatrixType
    let output: MatrixType
    
}
