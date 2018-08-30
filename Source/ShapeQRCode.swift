//
//  ShapeQRCode.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 30.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation

struct ShapeQRCode {
    let text: String
    let image: Image?
    
    init(withText text: String, andImage image: Image?) {
        self.text = text
        self.image = image
    }
    
//    var image: UIImage {
//
//    }
}

extension ShapeQRCode {
    struct Image {
        let sizeInPercent: CGSize
        
        init(withWidth widthPercent: CGFloat, height heightPercent: CGFloat) throws {
            //make sure the width and height values are in the allowed range
            guard (CGFloat(0.0)...CGFloat(1.0)).contains([widthPercent, heightPercent]) else {
                throw Image.Problem.percentValuesInappropriate
            }
            sizeInPercent = CGSize(width: widthPercent, height: heightPercent)
        }
        
        enum Problem: Error {
            case percentValuesInappropriate
        }
    }
}

