//
//  RangeExpression+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 30.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation

extension RangeExpression {
    public func contains(_ elements: [Bound]) -> Bool {
        return elements.allSatisfy { self.contains($0) }
    }
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}

extension Range where Bound: (FloatingPoint & Comparable) {
    ///Returns n evenly spaced samples from the range – if it isn't possible to generate n evenly spaced samples, it will return the same sample multiple times
    func evenlySpacedSamples(n: Int) -> [Bound] {
        let distance = upperBound-lowerBound
        let sampleDistance = distance/Bound(n)
        
        var samples: [Bound] = []
        for i in 0..<n {
            let sample = lowerBound+(Bound(i)*sampleDistance)
            guard sample < upperBound else {
                return samples
            }
            samples += [sample]
        }
        
        return samples
    }
}
