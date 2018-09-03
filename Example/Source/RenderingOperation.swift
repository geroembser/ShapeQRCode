//
//  RenderingOperation.swift
//  ShapeQRCode Example
//
//  Created by Gero Embser on 03.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation
import ShapeQRCode

class RenderingOperation: Operation {
    let shapeQRCode: ShapeQRCode
    let renderingResultHandler: ShapeQRCode.ShapeQRCodeRenderingCompletionHandler
    let length: CGFloat
    let integrityCheck: Bool
    let errorCorrectionOptimization: Bool
    
    init(withShapeQRCode shapeQRCode: ShapeQRCode,
         ofLength length: CGFloat,
         usingIntegrityCheck integrityCheck: Bool,
         withErrorCorrectionOptimization errorCorrectionOptimization: Bool,
         renderingResultHandler: @escaping ShapeQRCode.ShapeQRCodeRenderingCompletionHandler) {
        self.shapeQRCode = shapeQRCode
        self.renderingResultHandler = renderingResultHandler
        
        self.length = length
        self.integrityCheck = integrityCheck
        self.errorCorrectionOptimization = errorCorrectionOptimization
    }
    
    override func main() {
        if isCancelled {
            return //don't try to render
        }
        
        //render the image
        do {
            let image = try shapeQRCode.image(withLength: length,
                                              withIntegrityCheck: integrityCheck,
                                              errorCorrectionOptimization: errorCorrectionOptimization)
            
            guard !isCancelled else { return } //don't call completion handler
            
            
            //call rendering result handler
            renderingResultHandler(image, nil)
            
        }
        catch let error as ShapeQRCode.Problem.QRContainedImageEncodingProblem {
            guard !isCancelled else { return }
            
            renderingResultHandler(error.unreadableQRImage, error)
        }
        catch { fatalError() } //should not happen...
    }
    
    override func cancel() {
        super.cancel()
    }
    
}
