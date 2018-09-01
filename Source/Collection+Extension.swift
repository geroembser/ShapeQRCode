//
//  Range+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 30.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation

extension Collection where Element: Comparable {
    public func contains(_ elements: [Element]) -> Bool {
        return elements.allSatisfy { self.contains($0) }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
