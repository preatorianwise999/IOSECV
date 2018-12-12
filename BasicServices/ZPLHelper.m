//
//  ZPLHelper.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/27/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "ZPLHelper.h"

@interface ZPLHelper ()

@property(nonatomic) int width;
@property(nonatomic, strong) NSMutableString *commands;

@end

@implementation ZPLHelper

- (void)reset {
    self.commands = [[NSMutableString alloc] init];
    _rotation = 0;
}

- (void)setupHeaderWithLabelLength:(int)length {
    self.width = 580;
    [self.commands appendString:[NSString stringWithFormat:@"^XA^POI^PW%d^MNN^LL%d^LH0,0^CI28", self.width, length]];
}

- (void)setRotation:(int)rotation {
    _rotation = rotation;
    if(rotation == 90) {
        [self.commands appendString:@"^FWR"];
    }
    else if(rotation == 0) {
        [self.commands appendString:@"^FWN"];
    }
}

- (void)moveToX:(int)x y:(int)y {
    
    [self rotateCoordinateX:&x y:&y];
    [self.commands appendString:[NSString stringWithFormat:@"^FO%d,%d", x, y]];
}

- (void)rotateCoordinateX:(int*)ptrX y:(int*)ptrY {
    if(self.rotation == 90) {
        int temp = (*ptrX);
        *ptrX = self.width - (*ptrY);
        *ptrY = temp;
    }
}

- (void)drawImageWithDataString:(NSString*)dataStr byteCount:(NSInteger)bytes bytesPerRow:(NSInteger)bpr x:(int)x y:(int)y {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^GFA,%ld,%ld,%ld,%@^FS", bytes, bytes, (long)bpr, dataStr]];
}

- (void)drawBoxWithThickness:(int)e x:(int)x y:(int)y w:(int)w h:(int)h {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^GB%d,%d,%d^FS", w, h, e]];
}

- (void)drawLineWithThickness:(int)e x:(int)x y:(int)y {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^GB%d,%d,%d^FS", self.width, e, e]];
}

- (void)addWrappingText:(NSString*)text withFontHeight:(int)h x:(int)x y:(int)y {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^A0,%d,%d", h, h]];
    [self.commands appendString:[NSString stringWithFormat:@"^FB%d,10,,^FD%@^FS", self.width - 20, text]];
}

- (void)addWrappingText:(NSString*)text withFontHeight:(int)h x:(int)x y:(int)y boxWidth:(int)w textLines:(int)nLines {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^A0,%d,%d", h, h]];
    [self.commands appendString:[NSString stringWithFormat:@"^FB%d,%d,,J^FD%@^FS", w, nLines, text]];
}

- (void)addTextBox:(NSString*)text withBoxWidth:(int)w fontHeight:(int)h x:(int)x y:(int)y {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^A0,%d,%d", h, h]];
    [self.commands appendString:[NSString stringWithFormat:@"^TB,%d,%d", w, h - 1]];
    [self.commands appendString:[NSString stringWithFormat:@"^FD%@^FS", text]];
}

- (void)addText:(NSString*)text withFontHeight:(int)h x:(int)x y:(int)y {
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^A0,%d,%d", h, h]];
    [self.commands appendString:[NSString stringWithFormat:@"^FD%@^FS", text]];
}

- (void)addPDF417BarcodeWithString:(NSString*)str x:(int)x y:(int)y {
    
    // if barcode is not printed, it can be because the number of rows/columns is too small
    
    [self moveToX:x y:y];
    [self.commands appendString:[NSString stringWithFormat:@"^BY3,3^B7,5,5,7,20,N^FD%@^FS", str]];
}

- (void)addCustomCommand:(NSString*)command {
    [self.commands appendString:command];
}

- (NSString*)finish {
    
    if(self.rotation != 0) {
        self.rotation = 0;
    }
    
    [self.commands appendString:@"^XZ"];
    return self.commands;
}

- (NSString*)getCommands {
    return self.commands;
}

@end
