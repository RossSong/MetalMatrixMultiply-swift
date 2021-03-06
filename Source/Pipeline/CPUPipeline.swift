//
//  CPUPipeline.swift
//
//  Created by Otto Schnurr on 12/29/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Accelerate.vecLib

/// An interface for performing matrix mutliplication on the CPU.
struct CPUPipeline {

    static func multiply<Data: MultiplicationData>(
        _ data: Data,
        repeatCount: Int = 0
    ) throws {
        guard data.inputDimensionsAreValid else {
            throw PipelineError.invalidInputDimensions
        }
        guard data.outputDimensionsAreValid else {
            throw PipelineError.invalidOutputDimensions
        }
        guard repeatCount >= 0 else {
            throw PipelineError.invalidRepeatCount
        }
    
        let count = 1 + repeatCount
        for _ in 1...count { _multiply(data) }
    }
    
}


// MARK: Private
private func _multiply<Data: MultiplicationData>(_ data: Data) {
    assert(data.inputDimensionsAreValid)
    assert(data.outputDimensionsAreValid)
    
    cblas_sgemm(
        CblasRowMajor, CblasTrans, CblasNoTrans,
        Int32(data.output.rowCount), Int32(data.output.columnCount),
        Int32(data.inputB.rowCount),
        1.0,
        data.inputA.baseAddress, Int32(data.inputA.paddedColumnCount),
        data.inputB.baseAddress, Int32(data.inputB.paddedColumnCount),
        0.0,
        data.output.baseAddress, Int32(data.output.paddedColumnCount)
    )
}
