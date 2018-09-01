//
//  UIColor+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 31.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

extension UIColor {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let components = self.cgColor.components else { return nil }
        return (red: components[0],
                green: components[1],
                blue: components[2],
                alpha: components[3])
    }
}
