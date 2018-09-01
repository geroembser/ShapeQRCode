//
//  TestImages.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 01.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit
@testable import ShapeQRCode

enum TestImages: String {
    case blackAndWhite
    case black
    case white
    case transparent
    case halfTransparent
    
    var uiImage: UIImage {
        return UIImage(named: self.rawValue,
                       in: Bundle(for: ColorAverageTests.self), compatibleWith: nil)!
    }
}
