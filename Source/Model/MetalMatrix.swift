//
//  MetalMatrix.swift
//
//  Created by Otto Schnurr on 12/17/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal.MTLDevice

class MetalMatrix: ResizableBufferedMatrix {

    init?(
        rowCount: Int,
        columnCount: Int,
        columnCountAlignment: Int,
        device: MTLDevice
    ) {
        super.init(
            rowCount: rowCount,
            columnCount: columnCount,
            columnCountAlignment: columnCountAlignment,
            buffer: MetalBuffer(device: device)
        )
    }

}

class MetalBuffer: ResizableBuffer {
    
    var memory: UnsafeMutablePointer<Void> {
        guard let buffer = buffer else { return nil }
        return buffer.contents()
    }
    
    var length: Int { return buffer?.length ?? 0 }
    
    func resizeToLength(newLength: Int) -> Bool {
        guard newLength >= 0 else { return false }
        guard newLength != length else { return true }
        
        if newLength == 0 {
            buffer = nil
        } else if let buffer = buffer {
            self.buffer = buffer.resizedToLength(newLength)
        } else {
            buffer = device.newBufferWithLength(
                newLength, options: .CPUCacheModeDefaultCache
            )
        }
        
        return true
    }
    
    init(device: MTLDevice) { self.device = device }
    
    // MARK: Private
    private let device: MTLDevice
    private var buffer: MTLBuffer?
    
}


// MARK: - Private
private extension MTLBuffer {
    
    func resizedToLength(newLength: Int) -> MTLBuffer? {
        guard newLength != length else {
            return self
        }
        guard newLength > 0 else {
            return nil
        }
        
        let newBuffer: MTLBuffer
        
        if newLength > length {
            newBuffer = device.newBufferWithBytes(
                self.contents(),
                length: newLength,
                options: .CPUCacheModeDefaultCache
            )
        } else {
            newBuffer = device.newBufferWithLength(
                newLength, options: .CPUCacheModeDefaultCache
            )
            newBuffer.contents().assignFrom(self.contents(), count: newLength)
        }
        
        return newBuffer
    }
    
}
