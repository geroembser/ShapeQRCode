//
//  CGContext+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 02.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

//MARK: - get pixel data of CGContext

extension CGContext {
    struct PixelData {
        init(withImageWidth imageWidth: Int,
             imageHeight: Int,
             rawData: [UInt8]) {
            self.imageWidth = imageWidth
            self.imageHeight = imageHeight
            self.internalData = rawData
        }
        
        private let internalData: [UInt8]
        let imageWidth: Int
        let imageHeight: Int
        
        func isTransparent(pixelAtX x: UInt, y: UInt) -> Bool {
            return alphaValue(forPixel: x, y: y) == 0.0
        }
        
        func alphaValue(forPixel x: UInt, y: UInt) -> CGFloat {
            return CGFloat(rgba(forPixel: x, y: y).a)/255.0
        }
        
        ///Note: When using this method, make sure the pixel at (x,y) really exists, otherwise this will crash...
        func rgba(forPixel x: UInt, y: UInt) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
            let bytesPerPixel: Int = 4
            let bytesPerRow: Int = bytesPerPixel * imageWidth
            let byteIndex = (bytesPerRow * Int(y)) + Int(x) * bytesPerPixel;
            
            let r = internalData[byteIndex];
            let g = internalData[byteIndex + 1];
            let b = internalData[byteIndex + 2];
            let a = internalData[byteIndex + 3];
            
            return (r, g, b, a)
        }
    }
}

extension CGContext {
    func pixelData() -> PixelData? {
        let dataSize = width * height * 4
        var pixelData = [UInt8](repeating: 0, count: dataSize)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * width,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let cgImage = self.makeImage() else {
            return nil
        }
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return PixelData(withImageWidth: width, imageHeight: height, rawData: pixelData)
    }
}
