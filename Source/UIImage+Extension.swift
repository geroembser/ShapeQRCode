//
//  UIImage+Extension.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 31.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

//MARK: - average colors
public extension UIImage {
    ///If rect-parameter is nil, the entire image is taken
    ///Return value is nil if the rect isn't inside the image's bound
    public func averageColor(inRect rect: CGRect? = nil) -> UIColor? {
        guard let cicolor = CIImage(image: self)?.averageColor(inRect: rect) else {
            return nil
        }
        
        return UIColor(ciColor: cicolor)
    }
}

//MARK: - maximum alpha
extension UIImage {
    public func maximumAlpha(inRect rect: CGRect? = nil) -> CGFloat? {
        return CIImage(image: self)?.maximumAlpha(inRect: rect)
    }
}

//MARK: - qr code reading
extension UIImage {
    func qrReadInfo(forAccuracy accuracy: QRReadAccuracy) -> QRReadInfo? {
        return CIImage(image: self)?.qrReadInfo(forAccuracy:accuracy)
    }
    
    func containsReadableQRCode(forAccuracy accuracy: QRReadAccuracy) -> Bool {
        return qrReadInfo(forAccuracy: accuracy) != nil
    }
}

//MARK: - removing transparent background
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
