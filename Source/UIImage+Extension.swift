//
//  UIImage+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 31.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

public extension UIImage {
    ///If rect-parameter is nil, the entire image is taken
    ///Return value is nil if the rect isn't inside the image's bound
    public func averageColor(inRect rect: CGRect? = nil) -> UIColor? {
        guard let cicolor = CIImage(image: self)?.averageColor(inRect: rect) else {
            return nil
        }
        
        return UIColor(ciColor: cicolor)
    }
    
    public func maximumAlpha(inRect rect: CGRect? = nil) -> CGFloat? {
       return CIImage(image: self)?.maximumAlpha(inRect: rect)
    }
}


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
    
    func maximumAlpha(inRect rect: CGRect? = nil) -> CGFloat? {
        let vector = self.colorVector(forFilter: "CIAreaMaximumAlpha", inRect: rect)
        
        guard let alpha = vector?.last else {
            return nil
        }
        
        return CGFloat(alpha)/255.0
    }
    
    func transparent(inRect rect: CGRect? = nil) -> Bool {
        return maximumAlpha(inRect: rect) == 0.0
    }
}

fileprivate extension CIImage {
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

extension CIColor {
    var isFullTransparent: Bool {
        return self.alpha == 0.0
    }
}


//MARK: - qr code recognition
enum QRReadAccuracy {
    case low
    case high
    
    var ciDetectorAccuracy: String {
        switch self {
        case .low: return CIDetectorAccuracyLow
        case .high: return CIDetectorAccuracyHigh
        }
    }
}
typealias QRReadInfo = String

extension UIImage {
    func qrReadInfo(forAccuracy accuracy: QRReadAccuracy) -> QRReadInfo? {
        return CIImage(image: self)?.qrReadInfo(forAccuracy:accuracy)
    }
    
    func containsReadableQRCode(forAccuracy accuracy: QRReadAccuracy) -> Bool {
        return qrReadInfo(forAccuracy: accuracy) != nil
    }
}
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


extension UIImage {
    ///Removes the transparent background of an image and replaces it with a given color
    func removingTransparentBackground(byReplacingWith color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: self.size).image { (ctx) in
            let bounds = ctx.format.bounds
            
            //fill background
            color.setFill()
            ctx.fill(bounds)
            
            //draw the image on top
            self.draw(in: bounds)
        }
    }
}

extension UIColor {
    var complementaryColor: UIColor {
        let ciColor = CIColor(color: self)
        
        let compRed: CGFloat = 1.0 - ciColor.red
        let compGreen: CGFloat = 1.0 - ciColor.green
        let compBlue: CGFloat = 1.0 - ciColor.blue
        
        return UIColor(red: compRed, green: compGreen, blue: compBlue, alpha: 1.0)
    }
}
