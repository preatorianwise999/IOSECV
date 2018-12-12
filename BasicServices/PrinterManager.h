//
//  PrinterManager.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/26/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kErrorWrongLanguage,
    kErrorNoPrinter,
    kErrorInvalidInput,
    kErrorPrintingError
} PrinterErrorCode;

typedef enum {
    kStatusConnecting,
    kStatusSendingData,
    kStatusDisconnecting
} PrinterStatusCode;

@protocol PrinterDelegate <NSObject>

- (void)printerFinishedPrinting;
- (void)printerStatusChanged:(PrinterStatusCode)status;
- (void)printerFailedWithErrorCode:(PrinterErrorCode)error;

@end

@interface PrinterManager : NSObject

@property(nonatomic, weak) id<PrinterDelegate> delegate;
@property(nonatomic, strong) NSString *commands;

- (void)print;

@end
