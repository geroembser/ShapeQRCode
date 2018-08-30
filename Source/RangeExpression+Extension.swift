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
