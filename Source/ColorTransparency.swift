//
//  CIColor+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 02.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import CoreImage

extension CIColor {
    var isTransparent: Bool {
        return self.alpha == 0.0
    }
}

extension CGColor {
    var isTransparent: Bool {
        return self.alpha == 0.0
    }
}

extension UIColor{
    var isTransparent: Bool {
        return self.cgColor.isTransparent
    }
}
