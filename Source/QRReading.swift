//
//  QRReading.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 02.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation

//MARK: - qr code reading constants
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
