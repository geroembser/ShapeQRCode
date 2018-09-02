//
//  CGPoint.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 02.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

extension CGRect {
    ///Returns a randomPoint in the rect which isn't related to the rect's implied coordinate system. E. g. The origin of the rect is a possible random point that this method can return.
    func randomPoint() -> CGPoint {
        let x = CGFloat.random(in: self.origin.x...(self.origin.x+self.size.width))
        let y = CGFloat.random(in: self.origin.y...(self.origin.y+self.size.height))
        
        return CGPoint(x: x, y: y)
    }
}
