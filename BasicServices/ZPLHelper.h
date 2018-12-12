//
//  ZPLHelper.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/27/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPLHelper : NSObject

@property(nonatomic) int rotation;

- (void)reset;

- (void)setupHeaderWithLabelLength:(int)length;

- (void)drawImageWithDataString:(NSString*)dataStr byteCount:(NSInteger)bytes bytesPerRow:(NSInteger)bpr x:(int)x y:(int)y;

- (void)drawBoxWithThickness:(int)e x:(int)x y:(int)y w:(int)w h:(int)h;

- (void)drawLineWithThickness:(int)e x:(int)x y:(int)y;

- (void)addWrappingText:(NSString*)text withFontHeight:(int)h x:(int)x y:(int)y;

- (void)addWrappingText:(NSString*)text withFontHeight:(int)h x:(int)x y:(int)y boxWidth:(int)w textLines:(int)nLines;

- (void)addTextBox:(NSString*)text withBoxWidth:(int)w fontHeight:(int)h x:(int)x y:(int)y;

- (void)addText:(NSString*)text withFontHeight:(int)h x:(int)x y:(int)y;

- (void)addPDF417BarcodeWithString:(NSString*)str x:(int)x y:(int)y;

- (void)addCustomCommand:(NSString*)command;

- (NSString*)finish;

- (NSString*)getCommands;

@end
