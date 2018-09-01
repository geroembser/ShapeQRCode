//
//  ColorAverageTests.swift
//  ShapeQRCode iOSTests
//
//  Created by Gero Embser on 31.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import XCTest

///Some quick tests for testing some of the color average methods
class ColorAverageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension ColorAverageTests {
    func testBlackWhite() {
        AssertColorEqual(colorA: TestImages.blackAndWhite.uiImage.averageColor(),
                         colorB: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
    }
    
    func testBlack() {
        AssertColorEqual(colorA: TestImages.black.uiImage.averageColor(),
                         colorB: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
    }
    
    func testWhite() {
        AssertColorEqual(colorA: TestImages.white.uiImage.averageColor(),
                         colorB: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    }
    
    func testTransparent() {
        XCTAssertEqual(TestImages.transparent.uiImage.averageColor()?.colorComponents?.alpha, 0.0)
        
        XCTAssertEqual(TestImages.halfTransparent.uiImage.averageColor(inRect: CGRect(x: 1042, y: 0, width: 500, height: 500))?.colorComponents?.alpha, 0.0)
        
        AssertColorEqual(
            colorA: TestImages.halfTransparent.uiImage.averageColor(inRect: CGRect(x: 0, y: 0, width: 500, height: 500)),
            colorB: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
    }
}
