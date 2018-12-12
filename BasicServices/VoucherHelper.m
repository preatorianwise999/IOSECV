//
//  VoucherHelper.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 10/29/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "VoucherHelper.h"

#import "Flight.h"
#import "Passenger.h"
#import "Provider.h"
#import "PrinterManager.h"
#import "FoodService.h"
#import "TravelService.h"
#import "HotelService.h"
#import "CompensationService.h"
#import "CredentialsHelper.h"
#import "ZPLHelper.h"
#import "VoucherData.h"
#import "SaveHelper.h"
#import "Configuration.h"

@interface VoucherHelper ()

@end

@implementation VoucherHelper

/*
 
 NOTE(diego_cath): Actualmente la generación de ZPL está hard-codeada.
 Una posible mejora sería estructurar los vouchers en xml y crear un 
 traductor xml -> zpl
 
 */

- (VoucherData*)getVoucherDataForService:(NSObject*)service
                               passenger:(Passenger*)p
                               voucherID:(NSString*)voucherID
                          signatureImage:(UIImage*)signatureImage
                             isDuplicate:(BOOL)isDuplicate
                          commandsString:(NSString**)commands {
    
    if([service isKindOfClass:[FoodService class]]) {
        return [self getVoucherDataForFoodService:(FoodService*)service
                                        passenger:p
                                   signatureImage:signatureImage
                                      isDuplicate:(BOOL)isDuplicate
                                   commandsString:commands];
    
    } else if([service isKindOfClass:[TravelService class]]) {
        return [self getVoucherDataForTransportService:(TravelService*)service
                                             passenger:p
                                        signatureImage:signatureImage
                                           isDuplicate:(BOOL)isDuplicate
                                        commandsString:commands];
    
    } else if([service isKindOfClass:[HotelService class]]) {
        return [self getVoucherDataForHotelService:(HotelService*)service
                                         passenger:p
                                    signatureImage:signatureImage
                                       isDuplicate:(BOOL)isDuplicate
                                    commandsString:commands];
    
    } else if([service isKindOfClass:[CompensationService class]]) {
        return [self getVoucherDataForCompensationService:(CompensationService*)service
                                                passenger:p
                                                     foid:voucherID
                                           signatureImage:signatureImage
                                              isDuplicate:(BOOL)isDuplicate
                                           commandsString:commands];
    }
    
    return nil;
}

- (VoucherData*)getVoucherDataForFoodService:(FoodService*)service
                                   passenger:(Passenger*)p
                              signatureImage:(UIImage*)signatureImage
                                 isDuplicate:(BOOL)isDuplicate
                              commandsString:(NSString**)commands {
    
    CredentialsHelper *ch = [[CredentialsHelper alloc] init];
    NSString *usernameStr = [ch getUsername];
    
    // flight
    Flight *flight = p.flight;
    Flight *protectorFlight = service.flight;
    
    // date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    
    // voucher id
    NSString *voucherID = [self getVoucherIDForPassenger:p];
    
    if(commands) {
        // setup printer helper
        ZPLHelper *zplh = [[ZPLHelper alloc] init];
        [zplh reset];
        
        // Structure
        
        NSArray *providers = [flight.foodProviders allObjects];
        NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        providers = [providers sortedArrayUsingDescriptors:@[sortDesc]];
        int nRows = 0;
        if(providers.count > 0) {
            nRows = 1 + ((int)providers.count - 1)/2;
        }
        
        [zplh setupHeaderWithLabelLength:1290 + 42 * nRows + (service.signatureRequired.boolValue ? 220 : 0) + (service.printAmount.boolValue ? 90 : 0)];
        
        UIImage *logoImage = [UIImage imageNamed:@"logo_latam_ssbb"];
        NSString *logoStr = [self compressedHexRepresentationForImage:logoImage];
        [zplh drawImageWithDataString:logoStr byteCount:logoImage.size.width*logoImage.size.height/8 bytesPerRow:logoImage.size.width/8 x:42 y:40];
        
        [zplh drawLineWithThickness:1 x:10 y:200];
        [zplh addText:@"Alimentación / Food" withFontHeight:50 x:85 y:220];
        [zplh drawLineWithThickness:1 x:10 y:280];
        
        int y = 310;
        [zplh addWrappingText:@"Dispone de las siguientes alternativas / You have the following alternatives" withFontHeight:22 x:10 y:y];
        
        y += 15;
        for(int i = 0; i < providers.count; i++) {
            int x = (i % 2 == 0) ? 20 : 315;
            if(i % 2 == 0) {
                y += 42;
            }
            
            NSString *name = ((Provider*)providers[i]).name;
            
            int w = 0;
            do {
                if(w > 120) {
                    name = [NSString stringWithFormat:@"%@...", [name substringToIndex:name.length - 4]];
                }
                
                w = [[[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Roboto Condensed" size:14]}] size].width;
                
            } while(w > 120);
            
            [zplh addText:name withFontHeight:30 x:x y:y];
        }
        y += 55;
        
        [zplh addWrappingText:@"Tipo Alimentación (Snack o Comida) / Food type (Snack or Meal)" withFontHeight:22 x:10 y:y];
        [zplh addText:service.details withFontHeight:40 x:10 y:y + 50];
        y += 115;
        
        if(service.printAmount.boolValue) {
            [zplh addWrappingText:@"Monto / Amount" withFontHeight:22 x:10 y:y];
            [zplh addText:[NSString stringWithFormat:@"%@ %@", service.currency, service.amount] withFontHeight:40 x:10 y:y + 30];
            y += 90;
        }
        
        [zplh addWrappingText:@"Nombre Pax / Pax Name" withFontHeight:22 x:10 y:y];
        [zplh addText:[NSString stringWithFormat:@"%@ %@", [p.firstName uppercaseString], [p.lastName uppercaseString]] withFontHeight:40 x:10 y:y + 30];
        y += 90;
        
        [zplh addWrappingText:@"Vuelo Nº / Flight Nº" withFontHeight:18 x:10 y:y];
        [zplh addText:flight.flightName withFontHeight:35 x:10 y:y + 28];
        y += 82;
        
        [zplh addWrappingText:@"Origen-Destino / Origin-Destination" withFontHeight:18 x:10 y:y];
        [zplh addText:[NSString stringWithFormat:@"%@/%@", flight.departureAirport, flight.arrivalAirport] withFontHeight:35 x:10 y:y + 28];
        y += 82;
        
        [zplh addWrappingText:@"Fecha de Vuelo / Flight Date" withFontHeight:18 x:10 y:y];
        [zplh addText:[df stringFromDate:flight.departureDate] withFontHeight:35 x:10 y:y + 28];
        y += 82;
        
        NSDate *validDate = [NSDate dateWithTimeInterval:kVoucherDuration sinceDate:[NSDate date]];
        [zplh addWrappingText:@"Voucher válido hasta / Voucher valid until" withFontHeight:18 x:10 y:y];
        [zplh addText:[df stringFromDate:validDate] withFontHeight:35 x:10 y:y + 28];
        y += 100;
        
        df.dateStyle = NSDateFormatterNoStyle;
        df.dateFormat = @"dd-MM-yyyy";
        
        NSString *str = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@", flight.airlineCode, flight.flightNumber, flight.departureAirport, [df stringFromDate:flight.departureDate], p.passengerID, voucherID];
        
        [zplh addPDF417BarcodeWithString:str x:10 y:y];
        y += 110;
        
        [zplh addText:voucherID withFontHeight:18 x:10 y:y];
        y += 30;
        
        [zplh addWrappingText:@"Lamentamos los inconvenientes que esta situación pueda ocasionarle y agradecemos su comprensión / We regret any inconvenience this may cause you and appreciate your understanding" withFontHeight:18 x:10 y:y];
        y += 100;
        
        [zplh addWrappingText:@"Nombre Agente / Agent Name" withFontHeight:18 x:10 y:y];
        [zplh addText:usernameStr withFontHeight:35 x:10 y:y + 30];
        
        if([service.signatureRequired boolValue]) {
            
            y += 70;
            
            if(signatureImage != nil) {
                
                UIImage *resizedImage = [self imageWithImage:signatureImage convertToSize:CGSizeMake(360, 135)];
                NSString *hexImageDataString = [self compressedHexRepresentationForImage:resizedImage];
                [zplh drawImageWithDataString:hexImageDataString byteCount:resizedImage.size.width*resizedImage.size.height/8 bytesPerRow:resizedImage.size.width/8 x:100 y:y];
            }
            
            y += 150;
            [zplh drawBoxWithThickness:1 x:130 y:y w:300 h:1];
            [zplh addText:@"Firma pasajero" withFontHeight:22 x:200 y:y + 10];
        }
        
        *commands = [zplh finish];
//        NSLog(@"%@", *commands);
    }
    
    VoucherData *vd = [[VoucherData alloc] init];
    vd.serviceType = serviceFood;
    vd.username = usernameStr;
    vd.dateStr = [df stringFromDate:[NSDate date]];
    vd.providerName = @"-";
    vd.providerID = @0;
    vd.serviceName = service.details;
    vd.serviceCode = service.subCode;
    vd.idPassenger = p.passengerID.intValue;
    vd.airlineCode = flight.airlineCode;
    vd.flightNumber = flight.flightNumber;
    vd.departureAirport = flight.departureAirport;
    vd.departureDateStr = [df stringFromDate:flight.departureDate];
    vd.voucherID = voucherID;
    
    return vd;
}

- (VoucherData*)getVoucherDataForTransportService:(TravelService*)service
                                        passenger:(Passenger*)p
                                   signatureImage:(UIImage*)signatureImage
                                      isDuplicate:(BOOL)isDuplicate
                                   commandsString:(NSString**)commands {
    
    CredentialsHelper *ch = [[CredentialsHelper alloc] init];
    NSString *usernameStr = [ch getUsername];
    
    // flight
    Flight *flight = p.flight;
    Flight *protectorFlight = service.flight;
    
    // date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    
    // voucher id
    NSString *voucherID = [self getVoucherIDForPassenger:p];
    
    if(commands) {
        // setup printer helper
        ZPLHelper *zplh = [[ZPLHelper alloc] init];
        [zplh reset];
        
        // Structure
        
        [zplh setupHeaderWithLabelLength:1305 + ([service.signatureRequired boolValue] ? 180 : 0)];
        
        UIImage *logoImage = [UIImage imageNamed:@"logo_latam_ssbb"];
        NSString *logoStr = [self compressedHexRepresentationForImage:logoImage];
        [zplh drawImageWithDataString:logoStr byteCount:logoImage.size.width*logoImage.size.height/8 bytesPerRow:logoImage.size.width/8 x:42 y:40];
        
        [zplh drawLineWithThickness:1 x:10 y:200];
        [zplh addText:@"Transporte / Transport" withFontHeight:50 x:40 y:220];
        [zplh drawLineWithThickness:1 x:10 y:280];
        
        int y = 310;
        [zplh addWrappingText:@"Tipo Transporte (bus o taxi) / Transport type (bus or taxi)" withFontHeight:22 x:10 y:y];
        [zplh addText:service.details withFontHeight:40 x:10 y:y + 30];
        
        y += 90;
        [zplh addWrappingText:@"Nombre proveedor / Provider name" withFontHeight:22 x:10 y:y];
        [zplh addText:service.provider.name withFontHeight:40 x:10 y:y + 30];
        
        y += 90;
        [zplh addWrappingText:@"Nombre Pax / Pax Name" withFontHeight:22 x:10 y:y];
        [zplh addText:[NSString stringWithFormat:@"%@ %@", [p.firstName uppercaseString], [p.lastName uppercaseString]] withFontHeight:40 x:10 y:y + 30];
        
        y += 90;
        [zplh addWrappingText:@"Vuelo Nº / Flight Nº" withFontHeight:18 x:10 y:y];
        [zplh addText:flight.flightName withFontHeight:35 x:10 y:y + 28];
        
        y += 82;
        [zplh addWrappingText:@"Origen-Destino / Origin-Destination" withFontHeight:18 x:10 y:y];
        [zplh addText:[NSString stringWithFormat:@"%@/%@", flight.departureAirport, flight.arrivalAirport] withFontHeight:35 x:10 y:y + 28];
        
        y += 82;
        [zplh addWrappingText:@"Fecha de Vuelo / Flight Date" withFontHeight:18 x:10 y:y];
        [zplh addText:[df stringFromDate:flight.departureDate] withFontHeight:35 x:10 y:y + 28];
        
        NSDate *validDate = [NSDate dateWithTimeInterval:kVoucherDuration sinceDate:[NSDate date]];
        
        y += 82;
        [zplh addWrappingText:@"Voucher válido hasta / Voucher valid until" withFontHeight:18 x:10 y:y];
        [zplh addText:[df stringFromDate:validDate] withFontHeight:35 x:10 y:y + 28];
        
        df.dateStyle = NSDateFormatterNoStyle;
        df.dateFormat = @"dd-MM-yyyy";
        
        NSString *str = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@", flight.airlineCode, flight.flightNumber, flight.departureAirport, [df stringFromDate:flight.departureDate], p.passengerID, voucherID];
        
        y += 100;
        [zplh addPDF417BarcodeWithString:str x:10 y:y];
        y += 110;
        [zplh addText:voucherID withFontHeight:18 x:10 y:y];
        
        y += 30;
        [zplh addWrappingText:@"Lamentamos los inconvenientes que esta situación pueda ocasionarle y agradecemos su comprensión / We regret any inconvenience this may cause you and appreciate your understanding" withFontHeight:18 x:10 y:y];
        
        y += 100;
        [zplh addWrappingText:@"Nombre Agente / Agent Name" withFontHeight:18 x:10 y:y];
        [zplh addText:usernameStr withFontHeight:35 x:10 y:y + 30];
        
        if([service.signatureRequired boolValue]) {
            
            y += 70;
            
            if(signatureImage != nil) {
                
                UIImage *resizedImage = [self imageWithImage:signatureImage convertToSize:CGSizeMake(360, 135)];
                NSString *hexImageDataString = [self compressedHexRepresentationForImage:resizedImage];
                [zplh drawImageWithDataString:hexImageDataString byteCount:resizedImage.size.width*resizedImage.size.height/8 bytesPerRow:resizedImage.size.width/8 x:100 y:y];
            }
            
            y += 150;
            [zplh drawBoxWithThickness:1 x:130 y:y w:300 h:1];
            [zplh addText:@"Firma pasajero" withFontHeight:22 x:200 y:y + 10];
        }
        
        *commands = [zplh finish];
//        NSLog(@"%@", *commands);
    }
    
    df.dateStyle = NSDateFormatterNoStyle;
    df.dateFormat = @"dd-MM-yyyy";
    
    VoucherData *vd = [[VoucherData alloc] init];
    vd.serviceType = serviceTransport;
    vd.username = usernameStr;
    vd.dateStr = [df stringFromDate:[NSDate date]];
    vd.providerName = service.provider.name;
    vd.providerID = service.provider.providerID;
    vd.serviceName = service.details;
    vd.serviceCode = service.subCode;
    vd.idPassenger = p.passengerID.intValue;
    vd.airlineCode = flight.airlineCode;
    vd.flightNumber = flight.flightNumber;
    vd.departureAirport = flight.departureAirport;
    vd.departureDateStr = [df stringFromDate:flight.departureDate];
    vd.voucherID = voucherID;
    
    return vd;
}

- (VoucherData*)getVoucherDataForHotelService:(HotelService*)service
                                    passenger:(Passenger*)p
                               signatureImage:(UIImage*)signatureImage
                                  isDuplicate:(BOOL)isDuplicate
                               commandsString:(NSString**)commands {
    
    CredentialsHelper *ch = [[CredentialsHelper alloc] init];
    NSString *usernameStr = [ch getUsername];
    
    // flight
    Flight *flight = p.flight;
    Flight *protectorFlight = service.flight;

    // date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    
    // voucher id
    NSString *voucherID = [self getVoucherIDForPassenger:p];
    
    if(commands) {
        // setup printer helper
        ZPLHelper *zplh = [[ZPLHelper alloc] init];
        [zplh reset];
        
        // Structure
        
        [zplh setupHeaderWithLabelLength:1330 + ([service.signatureRequired boolValue] ? 180 : 0)];
        
        UIImage *logoImage = [UIImage imageNamed:@"logo_latam_ssbb"];
        NSString *logoStr = [self compressedHexRepresentationForImage:logoImage];
        [zplh drawImageWithDataString:logoStr byteCount:logoImage.size.width*logoImage.size.height/8 bytesPerRow:logoImage.size.width/8 x:42 y:40];
        
        [zplh drawLineWithThickness:1 x:10 y:200];
        [zplh addText:@"Hotel" withFontHeight:50 x:240 y:220];
        [zplh drawLineWithThickness:1 x:10 y:280];
        
        int y = 310;
        [zplh addWrappingText:@"Nombre Hotel / Hotel name" withFontHeight:22 x:10 y:y];
        [zplh addText:[service.provider.name uppercaseString] withFontHeight:40 x:10 y:y + 30];
        
        y += 90;
        [zplh addWrappingText:@"Tipo habitación (single o doble) / Room type (single or double)" withFontHeight:22 x:10 y:y];
        [zplh addText:[service.roomTypeDesc uppercaseString] withFontHeight:40 x:10 y:y + 50];
        
        y += 115;
        [zplh addWrappingText:@"Nombre Pax / Pax Name" withFontHeight:22 x:10 y:y];
        [zplh addText:[NSString stringWithFormat:@"%@ %@", [p.firstName uppercaseString], [p.lastName uppercaseString]] withFontHeight:40 x:10 y:y + 30];
        
        y += 90;
        [zplh addWrappingText:@"Vuelo Nº / Flight Nº" withFontHeight:18 x:10 y:y];
        [zplh addText:flight.flightName withFontHeight:35 x:10 y:y + 28];
        
        y += 82;
        [zplh addWrappingText:@"Origen-Destino / Origin-Destination" withFontHeight:18 x:10 y:y];
        [zplh addText:[NSString stringWithFormat:@"%@/%@", flight.departureAirport, flight.arrivalAirport] withFontHeight:35 x:10 y:y + 28];
        
        y += 82;
        [zplh addWrappingText:@"Fecha de Vuelo / Flight Date" withFontHeight:18 x:10 y:y];
        [zplh addText:[df stringFromDate:flight.departureDate] withFontHeight:35 x:10 y:y + 28];
        
        NSDate *validDate = [NSDate dateWithTimeInterval:kVoucherDuration sinceDate:[NSDate date]];
        
        y += 82;
        [zplh addWrappingText:@"Voucher válido hasta / Voucher valid until" withFontHeight:18 x:10 y:y];
        [zplh addText:[df stringFromDate:validDate] withFontHeight:35 x:10 y:y + 28];
        
        df.dateStyle = NSDateFormatterNoStyle;
        df.dateFormat = @"dd-MM-yyyy";
        
        NSString *str = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@", flight.airlineCode, flight.flightNumber, flight.departureAirport, [df stringFromDate:flight.departureDate], p.passengerID, voucherID];
        
        y += 100;
        [zplh addPDF417BarcodeWithString:str x:10 y:y];
        
        y += 110;
        [zplh addText:voucherID withFontHeight:18 x:10 y:y];
        
        y += 30;
        [zplh addWrappingText:@"Lamentamos los inconvenientes que esta situación pueda ocasionarle y agradecemos su comprensión / We regret any inconvenience this may cause you and appreciate your understanding" withFontHeight:18 x:10 y:y];
        
        y += 100;
        [zplh addWrappingText:@"Nombre Agente / Agent Name" withFontHeight:18 x:10 y:y];
        [zplh addText:usernameStr withFontHeight:35 x:10 y:y + 30];
        
        if([service.signatureRequired boolValue]) {
            
            y += 70;
            
            if(signatureImage != nil) {
                
                UIImage *resizedImage = [self imageWithImage:signatureImage convertToSize:CGSizeMake(360, 135)];
                NSString *hexImageDataString = [self compressedHexRepresentationForImage:resizedImage];
                [zplh drawImageWithDataString:hexImageDataString byteCount:resizedImage.size.width*resizedImage.size.height/8 bytesPerRow:resizedImage.size.width/8 x:100 y:y];
            }
            
            y += 150;
            [zplh drawBoxWithThickness:1 x:130 y:y w:300 h:1];
            [zplh addText:@"Firma pasajero" withFontHeight:22 x:200 y:y + 10];
        }
        
        *commands = [zplh finish];
//        NSLog(@"%@", *commands);
    }
    
    df.dateStyle = NSDateFormatterNoStyle;
    df.dateFormat = @"dd-MM-yyyy";
    
    VoucherData *vd = [[VoucherData alloc] init];
    vd.serviceType = serviceHotel;
    vd.username = usernameStr;
    vd.dateStr = [df stringFromDate:[NSDate date]];
    vd.providerName = service.provider.name;
    vd.providerID = service.provider.providerID;
    vd.serviceName = service.roomTypeDesc;
    vd.serviceCode = service.subCode;
    vd.idPassenger = p.passengerID.intValue;
    vd.airlineCode = flight.airlineCode;
    vd.flightNumber = flight.flightNumber;
    vd.departureAirport = flight.departureAirport;
    vd.departureDateStr = [df stringFromDate:flight.departureDate];
    vd.voucherID = voucherID;
    
    return vd;
}

- (VoucherData*)getVoucherDataForCompensationService:(CompensationService*)service
                                           passenger:(Passenger*)p
                                                foid:(NSString*)foid
                                      signatureImage:(UIImage*)signatureImage
                                         isDuplicate:(BOOL)isDuplicate
                                      commandsString:(NSString**)commands {
    
    CredentialsHelper *ch = [[CredentialsHelper alloc] init];
    NSString *usernameStr = [ch getUsername];
    
    // flights
    Flight *flight = p.flight;
    Flight *protectorFlight = service.flight;
    
    // date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    
    // voucher id
    NSString *voucherID = foid;
    
    if(commands) {
        // setup printer helper
        ZPLHelper *zplh = [[ZPLHelper alloc] init];
        [zplh reset];
        
        // Structure
        
        [zplh setupHeaderWithLabelLength:1305];
        
        zplh.rotation = 90;
        
        // COLUMNA 1
        
        NSString *locale = NSLocalizedString(@"locale", @"en, es, pt");
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterSpellOutStyle;
        formatter.maximumFractionDigits = 2;
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:@{NSLocaleLanguageCode: locale}]];
        
        int x = 40;
        int y = 53;
        
        [zplh addText:@"TRAVEL VOUCHER" withFontHeight:40 x:x y:y];
        y += 32;
        
        [zplh addText:[NSString stringWithFormat:@"Nº %@", voucherID] withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:NSLocalizedString(@"compensation_pax_name", @"NOMBRE PASAJERO") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:[NSString stringWithFormat:@"%@ %@", p.firstName, p.lastName] withFontHeight:30 x:x y:y];
        y += 35;
        
        [zplh addText:NSLocalizedString(@"compensation_flight/date", @"VUELO/FECHA") withFontHeight:20 x:x y:y];
        y += 30;
        
        df.dateFormat = @"dd MMM yy";
        [zplh addText:[NSString stringWithFormat:@"%@ / %@", flight.flightName, [df stringFromDate:flight.departureDate]] withFontHeight:30 x:x y:y];
        y += 35;
        
        [zplh addText:NSLocalizedString(@"compensation_option_A", @"1 - OPCION A") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:NSLocalizedString(@"compensation_option_A_desc", @"CANJEABLE SOLO POR SERVICIOS LAN") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:NSLocalizedString(@"compensation_amount", @"MONTO") withFontHeight:20 x:x y:y];
        y += 30;
        
        NSString *amountStr1 = [NSString stringWithFormat:@"%d USD", [service.servicesAmount intValue]];
        int w1 = [[[NSAttributedString alloc] initWithString:amountStr1 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Roboto Condensed" size:28]}] size].width;
        [zplh addText:amountStr1 withFontHeight:30 x:x y:y];
        [zplh addText:[NSString stringWithFormat:@"(%@)", [formatter stringFromNumber:@([service.servicesAmount intValue])]] withFontHeight:20 x:x + w1 + 12 y:y - 5];
        y += 35;
        
        [zplh addText:NSLocalizedString(@"compensation_option_B", @"2 - OPCION B") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:[NSLocalizedString(@"compensation_option_B_desc", @"money transfer") uppercaseString] withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:NSLocalizedString(@"compensation_amount", @"MONTO") withFontHeight:20 x:x y:y];
        y += 30;
        
        NSString *amountStr2 = [NSString stringWithFormat:@"%d USD", [service.cashAmount intValue]];
        int w2 = [[[NSAttributedString alloc] initWithString:amountStr2 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Roboto Condensed" size:28]}] size].width;
        [zplh addText:amountStr2 withFontHeight:30 x:x y:y];
        [zplh addText:[NSString stringWithFormat:@"(%@)", [formatter stringFromNumber:@([service.cashAmount intValue])]] withFontHeight:20 x:x + w2 + 12 y:y - 5];
        y += 35;
        
        if([service.upgrade boolValue]) {
            [zplh addText:NSLocalizedString(@"compensation_option_C", @"3 - OPCION C") withFontHeight:20 x:x y:y];
            y += 30;
            
            [zplh addText:[NSString stringWithFormat:@"UPGRADE (%@ / %@)", protectorFlight.flightName, [df stringFromDate:protectorFlight.departureDate]] withFontHeight:20 x:x y:y];
            y += 50;
        } else {
            y += 80;
        }
        
        [zplh addWrappingText:NSLocalizedString(@"compensation_footer_text", @"disclaimer")  withFontHeight:16 x:40 y:y boxWidth:900 textLines:2];

        // COLUMNA 2
        
        x = 450;
        y = 115;
        
        [zplh addText:NSLocalizedString(@"compensation_doc_details", @"TIPO/Nº ID/PAIS") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:[NSString stringWithFormat:@"%@/%@/%@", p.documentType, p.documentNumber, p.docIssuingCountry] withFontHeight:30 x:x y:y];
        y += 35;
        
        [zplh addText:NSLocalizedString(@"compensation_protector/date", @"VUELO PROTECCION/FECHA") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:[NSString stringWithFormat:@"%@ / %@", protectorFlight.flightName, [df stringFromDate:protectorFlight.departureDate]] withFontHeight:30 x:x y:y];
        y += 35;
        
        [zplh addText:NSLocalizedString(@"compensation_motive", @"MOTIVO") withFontHeight:20 x:x y:y];
        y += 30;
        
        [zplh addText:service.motive withFontHeight:30 x:x y:y];
        y += 35;
        
        if(isDuplicate == NO) {
            [zplh addText:NSLocalizedString(@"compensation_voluntary", @"VOLUNTARIEDAD") withFontHeight:20 x:x y:y];
            y += 30;
            
            [zplh addText:p.voluntary withFontHeight:30 x:x y:y];
            y += 35;
        }
        
        // COLUMNA 3
        
        x = 760;
        y = 74;
        
        UIImage *rotatedImage = [self rotateImage:[UIImage imageNamed:@"logo_latam_tv"] degrees:90.0];
        NSString *hexImageDataString = [self compressedHexRepresentationForImage:rotatedImage];
        [zplh drawImageWithDataString:hexImageDataString byteCount:rotatedImage.size.width*rotatedImage.size.height/8 bytesPerRow:rotatedImage.size.width/8 x:x + 100 y:y];
        
        y += 45;
        
        [zplh addText:NSLocalizedString(@"compensation_airport", @"AEROPUERTO") withFontHeight:20 x:x y:y];
        [zplh addText:NSLocalizedString(@"compensation_emission_date", @"FECHA DE EMISION") withFontHeight:20 x:x + 300 y:y];
        y += 30;
        
        NSString *iata = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
        [zplh addText:iata withFontHeight:30 x:x y:y];
        [zplh addText:[df stringFromDate:[NSDate date]] withFontHeight:30 x:x + 300 y:y];
        y += 300;
        
        [zplh addWrappingText:NSLocalizedString(@"compensation_legal_text", @"legal") withFontHeight:18 x:x y:y boxWidth:480 textLines:15];
        
        if(signatureImage != nil) {
            rotatedImage = [self rotateImage:signatureImage degrees:90.0];
            UIImage *resizedImage = [self imageWithImage:rotatedImage convertToSize:CGSizeMake(112, 288)];
            hexImageDataString = [self compressedHexRepresentationForImage:resizedImage];
            [zplh drawImageWithDataString:hexImageDataString byteCount:resizedImage.size.width*resizedImage.size.height/8 bytesPerRow:resizedImage.size.width/8 x:x + 80 + 6 y:y + 80];
        }
        
        y += 70;
        
        [zplh drawBoxWithThickness:1 x:x + 80 y:y w:1 h:300];
        y += 30;
        
        [zplh addText:NSLocalizedString(@"compensation_signature", @"FIRMA") withFontHeight:20 x:x + 200 y:y];
        y += 20;
        
        NSString *voucherTypeString = NSLocalizedString(@"compensation_airport_copy", @"ORIGINAL AEROPUERTO");
        if(isDuplicate) {
            voucherTypeString = NSLocalizedString(@"compensation_pax_copy", @"COPIA PASAJERO");;
        }
        
        [zplh addText:voucherTypeString withFontHeight:18 x:x + 310 y:y];
        
        *commands = [zplh finish];
//        NSLog(@"%@", *commands);
    }
    
    df.dateStyle = NSDateFormatterNoStyle;
    df.dateFormat = @"dd-MM-yyyy";
    
    VoucherData *vd = [[VoucherData alloc] init];
    vd.serviceType = serviceCompensation;
    vd.username = usernameStr;
    vd.dateStr = [df stringFromDate:[NSDate date]];
    vd.providerName = @"LATAM";
    vd.providerID = @(-1);
    vd.serviceName = @"Compensation";
    vd.serviceCode = @"CO";
    vd.idPassenger = p.passengerID.intValue;
    vd.airlineCode = flight.airlineCode;
    vd.flightNumber = flight.flightNumber;
    vd.departureAirport = flight.departureAirport;
    vd.departureDateStr = [df stringFromDate:flight.departureDate];
    vd.voucherID = voucherID;
    
    return vd;
}

- (NSString*)getVoucherIDForPassenger:(Passenger*)p {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyMMddHHmmss";
    int voucherCounter = [[SaveHelper sharedInstance] loadIntForKey:kVoucherIndex];
    
    long long n1 = [[df stringFromDate:[NSDate date]] longLongValue];
    int n2 = voucherCounter;
    long long n3 = [p.passengerID intValue];
    
    return [[NSString stringWithFormat:@"%llx-%x-%llx", n1, n2, n3] uppercaseString];
}

//NOTE(diego_cath): width and height of resized image need to be divisible by 8 because of the way the encoding works. We rotate first because it might modify a little the size of the resulting image because of floating point conversions

- (NSString*)compressedHexRepresentationForImage:(UIImage*)image {
    
    //NOTE(diego_cath): this block is used to convert a string that represents a 4-bit binary number into a single hexadecimal digit
    
    NSString* (^hexForByte)(NSString*) = ^NSString*(NSString *binary) {
      
        if([binary isEqualToString:@"0000"]) {
            return @"0";
        }
        if([binary isEqualToString:@"0001"]) {
            return @"1";
        }
        if([binary isEqualToString:@"0010"]) {
            return @"2";
        }
        if([binary isEqualToString:@"0011"]) {
            return @"3";
        }
        if([binary isEqualToString:@"0100"]) {
            return @"4";
        }
        if([binary isEqualToString:@"0101"]) {
            return @"5";
        }
        if([binary isEqualToString:@"0110"]) {
            return @"6";
        }
        if([binary isEqualToString:@"0111"]) {
            return @"7";
        }
        if([binary isEqualToString:@"1000"]) {
            return @"8";
        }
        if([binary isEqualToString:@"1001"]) {
            return @"9";
        }
        if([binary isEqualToString:@"1010"]) {
            return @"A";
        }
        if([binary isEqualToString:@"1011"]) {
            return @"B";
        }
        if([binary isEqualToString:@"1100"]) {
            return @"C";
        }
        if([binary isEqualToString:@"1101"]) {
            return @"D";
        }
        if([binary isEqualToString:@"1110"]) {
            return @"E";
        }
        if([binary isEqualToString:@"1111"]) {
            return @"F";
        }
        return @"0";
    };
    
    NSDictionary *countRepresentationCharacters = @{
                                                    @(1) : @('G'), @(2) : @('H'), @(3) : @('I'), @(4) : @('J'), @(5) : @('K'), @(6) : @('L'), @(7) : @('M'), @(8) : @('N'), @(9) : @('O'), @(10) : @('P'), @(11) : @('Q'), @(12) : @('R'), @(13) : @('S'), @(14) : @('T'), @(15) : @('U'), @(16) : @('V'), @(17) : @('W'), @(18) : @('X'), @(19) : @('Y'),
                                                    @(20) : @('g'), @(40) : @('h'), @(60) : @('i'), @(80) : @('j'), @(100) : @('k'), @(120) : @('l'), @(140) : @('m'), @(160) : @('n'), @(180) : @('o'), @(200) : @('p'), @(220) : @('q'), @(240) : @('r'), @(260) : @('s'), @(280) : @('t'), @(300) : @('u'), @(320) : @('v'), @(340) : @('w'), @(360) : @('x'), @(380) : @('y'), @(400) : @('z')};
    
    //NOTE(diego_cath): this block is used to convert a number into its ascii-hex compresion counterpart
    
    __block __weak NSString* (^weakGetCountRepresentation)(int);
    NSString* (^getCountRepresentation)(int);
    
    weakGetCountRepresentation = getCountRepresentation = ^NSString* (int count) {
      
        if(count > 400) {
            return [NSString stringWithFormat:@"%c%@", [countRepresentationCharacters[@(400)] charValue], weakGetCountRepresentation(count - 400)];
        }
        if(count > 20 && count % 20 != 0) {
            
            int n20 = count/20;
            return [NSString stringWithFormat:@"%c%@", [countRepresentationCharacters[@(n20*20)] charValue], weakGetCountRepresentation(count - n20*20)];
        }
        
        return [NSString stringWithFormat:@"%c", [countRepresentationCharacters[@(count)] charValue]];
    };
    
    //NOTE(diego_cath): this block is used to compress a hex number (represented as a string) using the ascii-hex compression format
    
    NSString* (^processLine)(NSString*) = ^NSString* (NSString *line) {
        NSMutableString *retVal = [[NSMutableString alloc] init];
        
        int index = 0;
        
        while(index < line.length) {
            char currentChar = [line characterAtIndex:index];
            int count = 0;
            while(index + count < line.length && [line characterAtIndex:index + count] == currentChar) {
                count++;
            }
            
            if(count == 1) {
                [retVal appendFormat:@"%c", currentChar];
            } else if(currentChar == '0' && index + count == line.length) {
                [retVal appendString:@","];
            } else {
                [retVal appendFormat:@"%@%c", getCountRepresentation(count), currentChar];
            }
            
            index += count;
        }
        
        return retVal;
    };
    
    //NOTE(diego_cath): here we take the input image and obtain a pixel representation of it
    
    NSString *currentHex = @"";
    NSString *currentLine = @"";
    NSString *prevLine;
    NSString *currentByte = @"";
    
    int x = 0, y = 0, count = image.size.width * image.size.height;
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    //NOTE(diego_cath): here we iterate through all pixels of the image, we transform pixels into bits, group bits into hex digits, group hex digits in a string and then compress the string.
    
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i) {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
        byteIndex += bytesPerPixel;
        
        float avg = (red + green + blue) / 3.0;
        
        if(avg > 127 || alpha < .1) {
            currentByte = [currentByte stringByAppendingString:@"0"];
        } else {
            currentByte = [currentByte stringByAppendingString:@"1"];
        }
        
        if(currentByte.length == 4) {
            currentLine = [currentLine stringByAppendingString:hexForByte(currentByte)];
            currentByte = @"";
        }
        if(currentLine.length*4 == width) {
            
            currentLine = processLine(currentLine);
            if([currentLine isEqualToString:prevLine]) {
                currentLine = @":";     //NOTE(diego_cath): in ascii-hex compression format, a colon is replaced by the previous line.
            } else {
                prevLine = currentLine;
            }
            
            currentHex = [currentHex stringByAppendingString:currentLine];
            currentLine = @"";
        }
    }
    
    free(rawData);
    
    return currentHex;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (UIImage*)rotateImage:(UIImage*)oldImage degrees:(CGFloat)degrees {
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = CGSizeMake(oldImage.size.height, oldImage.size.width);
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
