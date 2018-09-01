//
//  QRCode.h
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 30.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrcodegen.h"

NS_ASSUME_NONNULL_BEGIN

///Error correction level of the QR code
typedef NS_ENUM(NSInteger, QRCodeErrorCorrectionLevel) {
    low = 0,
    medium,
    quartile,
    high
};

@interface QRCode : NSObject
@property NSString *text;
@property int size;
-(id)initWithText:(NSString *)text andErrorCorrectionLevel:(QRCodeErrorCorrectionLevel)errorCorrectionLevel;
-(BOOL)getModuleForPositionX:(int)x andY:(int)y;
@end

NS_ASSUME_NONNULL_END
