//
//  QRCode.m
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 30.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

#import "QRCode.h"

@interface QRCode ()

@property uint8_t *qr;
@property QRCodeErrorCorrectionLevel errorCorrectionLevel;
@end

@implementation QRCode
- (void)createMatrix {
    self.qr = calloc(qrcodegen_BUFFER_LEN_MAX, sizeof(uint8_t));
    uint8_t tempBuffer[qrcodegen_BUFFER_LEN_MAX];
    bool ok = qrcodegen_encodeText([self.text UTF8String],
                                   tempBuffer, self.qr, (enum qrcodegen_Ecc)self.errorCorrectionLevel,
                                   qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX,
                                   qrcodegen_Mask_AUTO, true);
    if (!ok)
        return;
    
    self.size = qrcodegen_getSize(self.qr);
}
- (id)initWithText:(NSString *)text andErrorCorrectionLevel:(QRCodeErrorCorrectionLevel)errorCorrectionLevel {
    self = [super init];
    
    self.text = text;
    self.errorCorrectionLevel = errorCorrectionLevel;
    
    [self createMatrix];
    
    return self;
}
- (BOOL)getModuleForPositionX:(int)x andY:(int)y {
    return qrcodegen_getModule(self.qr, x, y);
}

- (void)dealloc
{
    free(self.qr);
}
@end
