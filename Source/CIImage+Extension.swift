//
//  CIImage+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 02.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import CoreImage


//MARK: - average color
extension CIImage {
    func averageColor(inRect rect: CGRect? = nil) -> CIColor? {
        guard let bitmap = colorVector(forFilter: "CIAreaAverage", inRect: rect) else {
            return nil
        }
        
        return CIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}

//MARK: - maximum alpha
extension CIImage {
    func maximumAlpha(inRect rect: CGRect? = nil) -> CGFloat? {
        let vector = self.colorVector(forFilter: "CIAreaMaximumAlpha", inRect: rect)
        
        guard let alpha = vector?.last else {
            return nil
        }
        
        return CGFloat(alpha)/255.0
    }
    
    ///Returns true if the CIImage is fully transparent in the given rect (i. e there's no intransparent pixel in the rect)
    func transparent(inRect rect: CGRect? = nil) -> Bool {
        return maximumAlpha(inRect: rect) == 0.0
    }
}


//MARK: - reading information from CIFilter results
fileprivate extension CIImage {
    ///Returns the vector of color for a given filter that returns an 1x1-pixel-image
    func colorVector(forFilter filter: String, inRect rect: CGRect? = nil) -> [UInt8]? {
        let rect = rect ?? self.extent
        
        //make sure rect is inside the image's extents
        guard self.extent.contains(rect) else {
            return nil
        }
        
        let extent = CIVector(x: rect.origin.x, y: rect.origin.y, z: rect.size.width, w: rect.size.height)
        
        guard let filter = CIFilter(name: filter, parameters: [kCIInputImageKey: self,
                                                               kCIInputExtentKey: extent]) else {
                                                                return nil
        }
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [CIContextOption.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return bitmap
    }
}

//MARK: - qr code detectino in CIImages
extension CIImage {
    func qrReadInfo(forAccuracy accuracy: QRReadAccuracy) -> QRReadInfo? {
        //create detector
        let options = [CIDetectorAccuracy: accuracy.ciDetectorAccuracy]
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)!
        
        var decode: String?
        
        let features = detector.features(in: self)
        for feature in features as! [CIQRCodeFeature] {
            decode = feature.messageString
        }
        
        guard let decoded = decode, !decoded.isEmpty else {
            return nil
        }
        
        return (decoded)
    }
}

