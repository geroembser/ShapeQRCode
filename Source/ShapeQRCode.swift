//
//  ShapeQRCode.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 30.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation
import UIKit
import NayukiQR

public struct ShapeQRCode {
    public var text: String {
        didSet {
            //update QR code
            self.updateQR()
        }
    }
    public var image: Image?
    public var moduleSpacingPercent: CGFloat
    public var shape: Shape
    public var color: UIColor
    
    private var qr: QRCode
    public var errorCorrectionLevel: ErrorCorrectionLevel {
        didSet {
            //update QR code
            self.updateQR()
        }
    }
    
    public init(withText text: String,
                andImage image: Image?,
                shape: Shape,
                moduleSpacingPercent: CGFloat = 0.003,
                color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                errorCorrectionLevel: ErrorCorrectionLevel = .medium) {
        self.text = text
        self.image = image
        self.shape = shape
        self.color = color
        self.errorCorrectionLevel = errorCorrectionLevel
        
        self.qr = QRCode(text: text, andErrorCorrectionLevel: errorCorrectionLevel.objcRepresentation);
        
        //verifiy whether we can use the given module spacing or not (we can use a module spacing that results at least in a module width/height of zero!)
        if (0.0...1.0).contains(moduleSpacingPercent*CGFloat(self.qr.size)) {
            self.moduleSpacingPercent = moduleSpacingPercent
        }
        else {
            self.moduleSpacingPercent = 0.0 //no module spacing otherwise
        }
    }
    
    private mutating func updateQR() {
        self.qr = QRCode(text: text, andErrorCorrectionLevel: self.errorCorrectionLevel.objcRepresentation);
    }
}

//MARK: - drawing QR code
extension ShapeQRCode {
    enum TransparencyDetectionMode {
        ///may be more appropriate for most cases
        case perfect
        ///may be faster in some cases
        case random
    }
}

//NOTE: https://bugs.swift.org/browse/SR-631
extension CGContext.PixelData {
    ///Use this method to extract information about the transparency values of a pixel-data snapshot
    func isFullTransparent(inRect rect: CGRect,
                           usingPixelsPerPointValue pixelsPerPoint: CGFloat,
                           withTransparencyDetectionMode transparencyDetectionMode: ShapeQRCode.TransparencyDetectionMode = .perfect) -> Bool {
        //the number of pixels in width covered by the rect
        let pixelsInWidth = Int(rect.width*pixelsPerPoint)
        let pixelsInHeight = Int(rect.height*pixelsPerPoint)
        
        //differ between the different methods
        switch transparencyDetectionMode {
        case .random:
            //compute the upper bound of pixels in the rect
            let pixelsInRect = pixelsInWidth*pixelsInHeight
            
            for _ in 0..<((20...50).clamp(pixelsInRect)) {
                let randomPoint = rect.randomPoint()
                
                //convert point to pixel
                let pixelX = UInt(randomPoint.x*pixelsPerPoint)
                let pixelY = UInt(randomPoint.y*pixelsPerPoint)
                
                if !self.isTransparent(pixelAtX: pixelX, y: pixelY) {
                    return false
                }
            }
            
            return true //assume it is full transparent, because by random we haven't found any intransparent pixel
        case .perfect:
            let originPixelIndexX = Int(rect.origin.x*pixelsPerPoint)
            let originPixelIndexY = Int(rect.origin.y*pixelsPerPoint)
            //iterate over all pixels in the pixelData
            for x in originPixelIndexX..<originPixelIndexX+pixelsInWidth {
                for y in originPixelIndexY..<originPixelIndexY+pixelsInHeight {
                    if !self.isTransparent(pixelAtX: UInt(x), y: UInt(y)) {
                        return false
                    }
                }
            }
            
            return true
        }
    }
}

public extension ShapeQRCode {
    
    private func image(fromRenderer renderer: UIGraphicsImageRenderer) -> UIImage {
        ///The bounds of the image where we draw in
        let bounds = renderer.format.bounds

        //determine what we use to draw one QR code module
        let moduleDrawer = self.moduleDrawer(forShape: self.shape, andColor: self.color.cgColor)
        
        
        //determine, if we have a drawer for the image contained in the QR code
        var containedImageDrawer: ContainedImageDrawer? = nil
        if let image = self.image {
            containedImageDrawer = self.containedImageDrawer(forContainedImage: image)
        }
        
        
        
        //render the image and return it
        ///NOTE: UIKit configures the cgContext of the renderer in a way that it draws from top left corner, not from bottom left!!!
        return renderer.image { (ctx) in
            //draw image
            containedImageDrawer?(ctx)
            
            //The pixel data of the context that we're drawing in (required for efficient computation of where to draw the qr modules)
            let pixelData = ctx.cgContext.pixelData()
            
            //draw modules
            for x in 0..<qr.size {
                for y in 0..<qr.size {
                    //only draw if that position should be black
                    guard self.qr.getModuleForPositionX(Int32(x), andY: Int32(y)) else {
                        continue
                    }
                    
                    let moduleRect = self.moduleRect(atCoordinate: (x,y), inBounds: bounds)
                    
                    ///The number of pixels for one point (it is a scale in the CGContext, because this simplifies drawing)
                    let pixelsPerPoint = ctx.cgContext.userSpaceToDeviceSpaceTransform.a
                    if let image = self.image, let pixelData = pixelData { //if there's an image to draw contained in the qr code
                        let containedImageRect = self.rect(ofContainedImage: image, inBounds: bounds)
                        
                        if containedImageRect.intersects(moduleRect) {
                            
                            if !pixelData.isFullTransparent(inRect: moduleRect,
                                                           usingPixelsPerPointValue: pixelsPerPoint,
                                                           withTransparencyDetectionMode: .perfect) {
                                continue
                            }
                        }
                        
                    }
                    
                    //draw the actual module
                    moduleDrawer(ctx, (x,y))
                }
            }
        }
    }
    
    ///Returns an image that has the size in points as specified by the length parameter
    ///The scale factor determines how many pixels per point
    private func image(withLength length: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        
        //define the size of the image (in POINTS)
        let size = CGSize(width: length, height: length)
        
        //create the renderer for the given length and scale
        
        ///The renderer for the image
        let rendererFormat = UIGraphicsImageRendererFormat(for: UIScreen.main.traitCollection)
        rendererFormat.scale = scale
        
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        
        
        //return...
        return image(fromRenderer: renderer)
    }
    
    ///Returns a UIImage with a width and height (as specified in the length parameter) in POINTS.
    ///The resulting image may have more pixels than points, because the scale-factor (how many pixels we use for one point) is determined automatically by the device's hardware specifications.
    ///NOTE: it is possible that due to antialiasing, there are grey lines between the different modules of the QR code. to prevent antialiasing, use an appropriate size that remove antialiasing. -> TODO: add a method that automatically adjusts the length in pixels so that antialiasing-effect isn't visible.
    ///NOTE: encoding speed also depends on how much transparent areas the containedImage has (few transparent areas <-> faster ; much transparent areas <-> slower)
    public func image(withLength length: CGFloat = 1000.0,
                      withIntegrityCheck integrityCheck: Bool,
                      errorCorrectionOptimization: Bool = true) throws -> UIImage {
        
        //create the image
        let image = self.image(withLength: length)
        
        
        if integrityCheck {
            let qrReadable = image.removingTransparentBackground(byReplacingWith: self.color.complementaryColor).containsReadableQRCode(forAccuracy: .high) //low, so that it is easy scannable
            
            guard qrReadable else {
                if errorCorrectionOptimization {
                    //try to optimize
                    //1. try to increase error correction level, if possible
                    var currentShapeQRCodeInTest = self //copy, because struct
                    var optimizedImage: UIImage = image
                    while let currentErrorCorrectionLevel = currentShapeQRCodeInTest.errorCorrectionLevel.higher {
                        currentShapeQRCodeInTest.errorCorrectionLevel = currentErrorCorrectionLevel
                        
                        do {
                            let newImage = try currentShapeQRCodeInTest.image(withLength: length,
                                                                              withIntegrityCheck: true,
                                                                              errorCorrectionOptimization:  false)
                            return newImage
                        }
                        catch let error as Problem.QRContainedImageEncodingProblem {
                            optimizedImage = error.unreadableQRImage
                        }
                    }
                    
                    //2. try to decrease the image in the middle by various percent-values...
                    //TODO:...
                    
                    //if optimization failed, throw the appropriate error indicating that optimization failed, although we've tried to optimize it
                    throw Problem.QRContainedImageEncodingProblem.unreadableEvenAfterOptimization(unreadableQR: optimizedImage)
                }
                throw Problem.QRContainedImageEncodingProblem.unreadable(unreadableQR: image)
            }
            
        }
        
        //return the actual qr code image
        return image
    }
    public func image(withLength length: CGFloat) -> UIImage {
        return try! image(withLength: length, withIntegrityCheck: false, errorCorrectionOptimization: false)
    }
}

//MARK: draw shapes
private extension ShapeQRCode {
    typealias ShapeDrawer = (CGContext, CGRect) -> Void
    private func shapeDrawer(forShape shape: Shape, andColor fillColor: CGColor) -> ShapeDrawer {
        switch shape {
        case .circle:
            return { (context, rect) in
                context.setFillColor(fillColor)
                context.fillEllipse(in: rect)
            }
        case .square:
            return { (context, rect) in
                context.setFillColor(fillColor)
                context.fill(rect)
            }
        }
    }
}

//MARK: draw qr code modules
private extension ShapeQRCode {
    
    private func moduleSpacing(forSize size: CGSize) -> CGFloat {
        return size.width * moduleSpacingPercent
    }
    private func moduleLength(forSize size: CGSize) -> CGFloat {
        let moduleSpacing = self.moduleSpacing(forSize: size)
        
        return (size.width-CGFloat(qr.size-1)*moduleSpacing) / CGFloat(qr.size)
    }
    private func moduleDistance(forSize size: CGSize) -> CGFloat {
        return moduleLength(forSize:size)+moduleSpacing(forSize: size)
    }
    
    
    typealias ModuleCoordinate = (x: Int32, y: Int32)
    private func modulePosition(atCoordinate coordinate: ModuleCoordinate, inBounds bounds: CGRect) -> CGPoint {
        let moduleDistance = self.moduleDistance(forSize: bounds.size)
        
        return CGPoint(x: CGFloat(coordinate.x)*moduleDistance,
                       y: CGFloat(coordinate.y)*moduleDistance)
    }
    private func moduleRect(atCoordinate coordinate: ModuleCoordinate, inBounds bounds: CGRect) -> CGRect {
        let moduleLength = self.moduleLength(forSize: bounds.size)
        
        return CGRect(origin: modulePosition(atCoordinate: coordinate, inBounds: bounds),
                                size: CGSize(width: moduleLength,
                                             height: moduleLength))
    }
    
    
    
    
    
    typealias ModuleDrawer = (UIGraphicsImageRendererContext, _ moduleCoordinate: ModuleCoordinate) -> Void
    private func moduleDrawer(forShape shape: Shape, andColor fillColor: CGColor) -> ModuleDrawer {
        
        let shapeDrawer = self.shapeDrawer(forShape: shape, andColor: fillColor)
        
        return { rendererContext, moduleCoordinate  in
            ///The bounds of the image where we draw in
            let bounds = rendererContext.format.bounds
            
            //determine where to draw the module
            let moduleRect = self.moduleRect(atCoordinate: moduleCoordinate, inBounds: bounds)
            
            //render the module using the shape drawer
            shapeDrawer(rendererContext.cgContext, moduleRect)
        }
    }
    
}

//MARK: draw contained image
private extension ShapeQRCode {
    private func size(ofContainedImage containedImage: Image, inBounds bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.size.width*containedImage.sizeInPercent.width,
                      height: bounds.size.height*containedImage.sizeInPercent.height)
    }
    private func origin(ofContainedImage containedImage: Image, inBounds bounds: CGRect) -> CGPoint {
        let containedImageSize = size(ofContainedImage: containedImage, inBounds: bounds)
        
        return CGPoint(x: bounds.midX-containedImageSize.width/2,
                       y: bounds.midY-containedImageSize.height/2)
    }
    private func rect(ofContainedImage containedImage: Image, inBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: origin(ofContainedImage: containedImage, inBounds: bounds),
                      size: size(ofContainedImage: containedImage, inBounds: bounds))
    }
    
    typealias ContainedImageDrawer = (UIGraphicsImageRendererContext) -> Void
    
    private func containedImageDrawer(forContainedImage containedImage: Image) -> ContainedImageDrawer {
        
        return { renderContext in
            let bounds = renderContext.format.bounds
            
            //compute where to draw the contained image inside the bounds
            let containedImageRect = self.rect(ofContainedImage: containedImage, inBounds: bounds)
            
            //draw the uiimage using the method of UIKit, because this way we support resizing UIImages that can preserve vector data, because the UIImage class therefore takes care about appropriate resizing and orientation
            containedImage.rawImage.draw(in: containedImageRect)
            
            //NOTE: DEPENDING ON THE UIIMAGE RENDERED, THE RENDERING ABOVE MAY TAKE A SIGNIFICANTLY LARGE AMOUNT OF TIME – THIS CAN REALLY SLOW DOWN RENDERING, ESPECIALLY REALTIME ON THE MAIN THREAD - CONSIDER USING AN OPTIMIZED IMAGE FOR THE DEVICE WITH LESS TRANSPARENCY
        }
    }
}

//MARK: - images in the QR code
public extension ShapeQRCode {
    public struct Image {
        let sizeInPercent: CGSize
        let rawImage: UIImage
        
        public init(withUIImage rawImage: UIImage,
                    width widthPercent: CGFloat,
                    height heightPercent: CGFloat) throws {
            self.rawImage = rawImage
            
            //make sure the width and height values are in the allowed range
            guard (CGFloat(0.0)...CGFloat(1.0)).contains([widthPercent, heightPercent]) else {
                throw Problem.percentValuesInappropriate
            }
            sizeInPercent = CGSize(width: widthPercent, height: heightPercent)
        }
    }
}


//MARK: - different shapes
public extension ShapeQRCode {
    public enum Shape: CaseIterable {
        case circle
        case square
    }
}


//MARK: - Errors/Problems
public extension ShapeQRCode {
    public enum Problem: Error {
        case percentValuesInappropriate
        
        public enum QRContainedImageEncodingProblem: Error {
            case unreadable(unreadableQR: UIImage)
            case unreadableEvenAfterOptimization(unreadableQR: UIImage)
            
            public var unreadableQRImage: UIImage {
                switch self {
                case .unreadable(let unreadableQR), .unreadableEvenAfterOptimization(let unreadableQR):
                    return unreadableQR
                }
            }
        }
    }
}

//MARK: - error correction level
public extension ShapeQRCode {

    //A one-to-one mapping to QRCodeErrorCorrectionLevel
    public enum ErrorCorrectionLevel: CaseIterable {
        case low
        case medium
        case quartile
        case high
        
        var higher: ErrorCorrectionLevel? {
            return ErrorCorrectionLevel.allCases[safe: ErrorCorrectionLevel.allCases.index(after: ErrorCorrectionLevel.allCases.firstIndex(of: self)!)]
        }
        
        fileprivate var objcRepresentation: QRCodeErrorCorrectionLevel {
            switch self {
            case .low: return .low
            case .medium: return .medium
            case .quartile: return .quartile
            case .high: return .high
            }
        }
    }
}


//MARK: - maximum module spacing
public extension ShapeQRCode {
    public var maximumModuleSpacingInPercent: CGFloat {
        return 1.0/CGFloat(qr.size)
    }
}


//MARK: - rendering asynchronously
public extension ShapeQRCode {
    static let renderingQueue = DispatchQueue(label: "com.geroembser.ShapeQRCode.RenderingQueue", qos: .userInitiated, attributes: .concurrent)
    
    public typealias ShapeQRCodeRenderingCompletionHandler = (UIImage, Error?) -> Void
    ///Renders the ShapeQRCode as a UIImage on a background thread and calls the given closure when completed (with an error or the sucessfully rendered image)
    public func asyncImage(withLength length: CGFloat = 1000.0,
                           withIntegrityCheck integrityCheck: Bool = true,
                           errorCorrectionOptimization: Bool = true,
                           withCompletionHandler completionHandler: @escaping ShapeQRCodeRenderingCompletionHandler) {
        ShapeQRCode.renderingQueue.async {
            do {
                //render the image
                let image = try self.image(withLength: length,
                                           withIntegrityCheck: integrityCheck,
                                           errorCorrectionOptimization: errorCorrectionOptimization)
                
                
                completionHandler(image, nil)
            }
            catch let error as Problem.QRContainedImageEncodingProblem {
                //error
                completionHandler(error.unreadableQRImage, error)
            }
            catch { return } //do nothing
        }
    }
}
