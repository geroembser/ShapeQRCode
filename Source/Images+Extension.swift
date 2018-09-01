//
//  Images+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 31.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

extension CGImage {
    func asCIImage() -> CIImage {
        return CIImage(cgImage: self)
    }
}

extension CIImage {
    func asCGImage() -> CGImage {
        if let image = self.cgImage {
            return image
        }
        
        return CIContext().createCGImage(self, from: self.extent)!
    }
}

extension UIImage {
    func asCGImage() -> CGImage {
        if let image = self.cgImage {
            return image
        }
        
        return self.ciImage!.asCGImage()
    }
}
