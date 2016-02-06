//
//  PerformanceTest.swift
//
//  Created by Otto Schnurr on 2/4/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Dispatch
import Metal

struct PerformanceTest {
    
    init?(
        device: MTLDevice,
        dimensionCapacity: Int = 2048,
        testCount: Int = 20,
        loopsPerTest: Int = 100
    ) {
        guard
            testCount > 0 && loopsPerTest > 0
        else { return nil }
        
        guard
            let resources = _createResourcesForDevice(
                device, dimensionCapacity: dimensionCapacity
            )
        else { return nil }
        
        self.resources = resources
        self.testCount = testCount
        self.loopsPerTest = loopsPerTest
    }

    func runAsync(completion: (success: Bool) -> Void) {
        let background = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        let foreground = dispatch_get_main_queue()
        
        dispatch_async(background) {
            let result: Bool

            do {
                try self.run()
                result = true
            } catch let error as PipelineError {
                _log("failure: \(error)")
                result = false
            } catch {
                _log("failure: unknown")
                result = false
            }

            dispatch_async(foreground) { completion(success: result) }
        }
    }

    // MARK: Private
    let resources: PerformanceTestCase.Resources
    let testCount: Int
    let loopsPerTest: Int

}


// MARK: - Private
private extension PerformanceTest {
    
    func run() throws {
        // !!!: implement me
    }
    
}

private func _createResourcesForDevice(
    device: MTLDevice, dimensionCapacity n: Int
) -> PerformanceTestCase.Resources? {
    guard
        let pipeline = MetalPipeline(device: device, countAlignment: 8),
        inputA = pipeline.newMatrixWithRowCount(n, columnCount: n),
        inputB = pipeline.newMatrixWithRowCount(n, columnCount: n),
        metalOutput = pipeline.newMatrixWithRowCount(n, columnCount: n),
        cpuOutput = CPUMatrix(rowCount: n, columnCount: n, countAlignment: 8)
    else { return nil }
    
    return PerformanceTestCase.Resources(
        metalPipeline: pipeline,
        inputA: inputA, inputB: inputB,
        metalOutput: metalOutput, cpuOutput: cpuOutput
    )
}

private func _log(message: String) {
    print(message)
}
