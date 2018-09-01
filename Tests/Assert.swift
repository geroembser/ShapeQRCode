//
//  Assert.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 01.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation
import XCTest

func AssertColorEqual(colorA a: UIColor?,
                      colorB b: UIColor?,
                      file: StaticString = #file,
                      line: UInt = #line) {
    
    guard let colorA = a, let colorB = b else {
        XCTAssertEqual(a, b, file: file, line: line)
        return
    }
    
    guard let compA = colorA.colorComponents, let compB = colorB.colorComponents else {
        XCTAssertEqual(a, b, file: file, line: line)
        return
    }
    
    let accuracy: CGFloat = 0.98
    XCTAssertEqual(compA.red, compB.red,
                   accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(compA.green, compB.green,
                   accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(compA.blue, compB.blue,
                   accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(compA.alpha, compB.alpha,
                   accuracy: accuracy, file: file, line: line)
}
