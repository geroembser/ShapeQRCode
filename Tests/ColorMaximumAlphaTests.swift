//
//  ColorMaximumAlphaTests.swift
//  ShapeQRCode iOSTests
//
//  Created by Gero Embser on 01.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import XCTest

class ColorMaximumAlphaTests: XCTestCase {
    func testMaximumAlphaHalfTransparent() {
        XCTAssertEqual(TestImages.halfTransparent.uiImage.maximumAlpha(inRect: CGRect(x: 0,
                                                                                      y: 0,
                                                                                      width: 500,
                                                                                      height: 500)), 1.0)
    }

}
