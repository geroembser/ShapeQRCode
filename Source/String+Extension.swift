//
//  String+Extension.swift
//  ShapeQRCode Example
//
//  Created by Gero Embser on 04.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

public extension String {
    ///Writes the string into a UIImage with the given font size
    public func image(ofSize size: CGSize, withFontSize fontSize: CGFloat = 50) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        (self as NSString).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    ///Creates an image with the string written in the given font size
    ///The size of the image is automatically determined by the text
    public func image(withFontSize fontSize: CGFloat = 250) -> UIImage? {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = self
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize)
        
        //size to fit, so that we get the size of the text
        label.sizeToFit()
        
        UIGraphicsBeginImageContextWithOptions(label.frame.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
