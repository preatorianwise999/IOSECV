//
//  DocumentPopupViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/25/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import "DocumentPopupViewController.h"
#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"
#import "UIFont+CommonValues.h"
#import "WebHelper.h"
#import "ModelHelper.h"
#import "ActivityIndicatorView.h"
#import "DocumentTypeDetails.h"

#pragma mark - Internal Data Structures

typedef enum {
    
    EditingCountry,
    EditingDocType
    
} EditionStatus;

@interface CountryDetails: NSObject

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *code;

@end

@implementation CountryDetails

@end

#pragma mark - DocumentData

@implementation DocumentData

@end

#pragma mark - DocumentPopupViewController

@interface DocumentPopupViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, WebHelperDelegate>

@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;

@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *docNumberExampleLabel;

@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *documentTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *documentNumberTextField;

@property (nonatomic) EditionStatus status;
@property (nonatomic) BOOL active;

@property (strong, nonatomic) NSArray *countriesArray;
@property (nonatomic) NSInteger selectedCountryIndex;
@property (strong, nonatomic) NSArray *docInfoArray;
@property (nonatomic) NSInteger selectedDocInfoIndex;

@property (strong, nonatomic) WebHelper *webHelper;

@end

@implementation DocumentPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/15.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    CGRect submitRect = self.updateButton.bounds;
    self.updateButton.backgroundColor = [UIColor clearColor];
    self.updateButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage drawRoundRectWithWidth:submitRect.size.width height:submitRect.size.height radius:submitRect.size.height/2 thickness:0 fillColor:[UIColor appDarkColorWithOpacity:1.0] borderColor:[UIColor clearColor]]];
    
    self.popupView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapInView)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    NSDictionary *contentDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *countriesInfoArray = (NSArray*)contentDict[@"countries"];
    
    NSMutableArray *countriesArray = [NSMutableArray new];
    for(NSDictionary *d in countriesInfoArray) {
        CountryDetails *country = [CountryDetails new];
        country.name = d[@"name"];
        country.code = d[@"code"];
        [countriesArray addObject:country];
    }
    self.countriesArray = countriesArray;
    
    // textFields borders
    
    self.countryTextField.layer.masksToBounds = NO;
    self.countryTextField.layer.shadowColor = [UIColor clearColor].CGColor;
    self.countryTextField.layer.shadowOffset = CGSizeZero;
    self.countryTextField.layer.shadowRadius = 10.0f;
    self.countryTextField.layer.shadowOpacity = .8f;
    
    self.documentTypeTextField.layer.masksToBounds = NO;
    self.documentTypeTextField.layer.shadowColor = [UIColor clearColor].CGColor;
    self.documentTypeTextField.layer.shadowOffset = CGSizeZero;
    self.documentTypeTextField.layer.shadowRadius = 10.0f;
    self.documentTypeTextField.layer.shadowOpacity = .8f;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.popupView.frame, [touch locationInView:self.view])) {
        return NO;
    }
    return YES;
}

- (IBAction)updateButtonTapped:(id)sender {
    
    [self hideSelectionPanel];
    [self.view endEditing:YES];
    
    self.countryLabel.textColor = [UIColor blackColor];
    self.documentTypeLabel.textColor = [UIColor blackColor];
    self.documentNumberLabel.textColor = [UIColor blackColor];
    
    if([self.countryTextField.text isEqualToString:@""]) {
        self.countryLabel.textColor = [UIColor redColor];
    } else if([self.documentTypeTextField.text isEqualToString:@""]) {
        self.documentTypeLabel.textColor = [UIColor redColor];
    } else {
        
        DocumentTypeDetails *docType = self.docInfoArray[self.selectedDocInfoIndex];
        NSString *mask = docType.mask;
        NSMutableString *pattern = [NSMutableString stringWithString:@"^"];
        NSInteger index = 0;
        int count = 0;
        char prevChar = [mask characterAtIndex:0];
        
        while(index <= mask.length) {
            
            char c;
            if(index < mask.length) {
                c = [mask characterAtIndex:index];
            }
            
            if(c == prevChar && index < mask.length) {
                count++;
            } else {
                
                if(prevChar == '0') {
                    [pattern appendFormat:@"\\d{0,%d}", count];
                } else if(prevChar == '9') {
                    [pattern appendFormat:@"\\d{%d}", count];
                } else if(prevChar == 'x') {
                    [pattern appendFormat:@"[a-zA-Z\\d]{0,%d}", count];
                } else if(prevChar == 'X') {
                    [pattern appendFormat:@"[a-zA-Z\\d]{%d}", count];
                } else {
                    [pattern appendFormat:@"%c{%d}", prevChar, count];
                }
                
                count = 1;
            }
            
            prevChar = c;
            index++;
        }
        
        [pattern appendFormat:@"$"];
        
        NSString *docNumber = self.documentNumberTextField.text;
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        NSArray *matches = [regex matchesInString:docNumber options:0 range:NSMakeRange(0, docNumber.length)];
        
        BOOL isValid = (matches.count == 1);
        
        if(isValid) {
            DocumentData *document = [DocumentData new];
            CountryDetails *country = self.countriesArray[self.selectedCountryIndex];
            DocumentTypeDetails *docType = self.docInfoArray[self.selectedDocInfoIndex];
            document.countryCode = country.code;
            document.documentType = docType.code;
            document.documentNumber = self.documentNumberTextField.text;
            [self.delegate documentPopupClosedWithNewDocument:document];
            [self hideAnimated];
        } else {
            self.documentNumberLabel.textColor = [UIColor redColor];
        }
    }
}

- (void)tapInView {
    [self hideAnimated];
}

- (void)showAnimated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    self.active = YES;
    
    self.view.hidden = NO;
    
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.popupView.alpha = 0;
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:.4].CGColor;
        self.popupView.alpha = 1;
    }];
    
    // clear/reset:
    
    self.selectedCountryIndex = -1;
    self.countryTextField.text = @"";
    
    self.selectedDocInfoIndex = -1;
    self.documentTypeLabel.enabled = NO;
    self.documentTypeTextField.enabled = NO;
    self.documentTypeTextField.text = @"";
    
    self.documentNumberLabel.enabled = NO;
    self.docNumberExampleLabel.text = @"";
    self.documentNumberTextField.enabled = NO;
    self.documentNumberTextField.text = @"";
    
    self.countryLabel.textColor = [UIColor blackColor];
    self.documentTypeLabel.textColor = [UIColor blackColor];
    self.documentNumberLabel.textColor = [UIColor blackColor];
}

- (void)hideAnimated {
    
    self.active = NO;
    
    [self hideSelectionPanel];
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.popupView.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Convenience

- (void)searchCountry:(NSString*)text {
    
    __block __weak NSInteger (^weakBinarySearch)(NSArray*, NSString*, NSInteger, NSInteger);
    NSInteger (^binarySearch)(NSArray*, NSString*, NSInteger, NSInteger);
    
    weakBinarySearch = binarySearch = ^NSInteger(NSArray *list, NSString *str, NSInteger start, NSInteger end) {
        
        if(start >= list.count) {
            return list.count - 1;
        } else if(end - start <= 1) {
            return start;
        }
        
        NSInteger mid = start + (end - start)/2;
        CountryDetails *data = list[mid];
        NSString *s = data.name;
        NSComparisonResult result = [str caseInsensitiveCompare:s];
        
        if(mid > 0) {
            CountryDetails *prevData = list[mid - 1];
            NSString *prevS = prevData.name;
            if([s rangeOfString:str].location == 0 && [prevS rangeOfString:str].location != 0) {
                result = NSOrderedSame;
            }
        }
        
        if(result == NSOrderedSame) {
            return mid;
        } else if(result == NSOrderedAscending) {
            return weakBinarySearch(list, str, start, mid);
        } else {
            return weakBinarySearch(list, str, mid + 1, end);
        }
        
        return 0;
    };
    
    NSInteger index = binarySearch(self.countriesArray, [text uppercaseString], 0, self.countriesArray.count);
    [self.optionsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)selectCountryAtIndex:(NSInteger)index {
    
    if(index == self.selectedCountryIndex && self.docInfoArray.count > 0) {
        return;
    }
    if(self.active == NO) {
        return;
    }
    
    self.selectedCountryIndex = index;
    self.selectedDocInfoIndex = -1;
    
    CountryDetails *data = self.countriesArray[index];
    self.countryTextField.text = data.name;
    self.documentTypeLabel.enabled = NO;
    self.documentTypeTextField.text = @"";
    self.documentTypeTextField.enabled = NO;
    self.documentNumberLabel.enabled = NO;
    self.docNumberExampleLabel.text = @"";
    self.documentNumberTextField.text = @"";
    self.documentNumberTextField.enabled = NO;
    
    self.docInfoArray = @[];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_getting_doc_types", @"Retrieving Document Types")];
    });
    
    self.webHelper = [[WebHelper alloc] init];
    self.webHelper.delegate = self;
    [self.webHelper testServerConnection];
}

- (void)showSelectionPanel {
    self.widthConstraint.constant = 520;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideSelectionPanel {
    self.widthConstraint.constant = 640;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    [self turnOffTextFieldsHighlight];
}

- (void)turnOffTextFieldsHighlight {
    self.countryTextField.layer.shadowColor = [UIColor clearColor].CGColor;
    self.documentTypeTextField.layer.shadowColor = [UIColor clearColor].CGColor;
}

#pragma mark WebHelperDelegate methods

- (void)serverConnectionTestEndedWithResult:(BOOL)serverReachable {
    
    if(serverReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.webHelper.delegate = self;
            CountryDetails *data = self.countriesArray[self.selectedCountryIndex];
            [self.webHelper requestTypesOfDocumentsForCountryCode:data.code];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ActivityIndicatorView getSharedInstance] stopAnimation];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                            message:NSLocalizedString(@"alert_msg_no_connection", @"No Connection")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)serverRespondedWithData:(NSData *)data forRequestType:(RequestType)type {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
    });
    
    if(type == kRequestDocumentTypes) {
        BOOL success = YES;  //TODO: get this from JSON
        if(success) {
            
            ModelHelper *model = [ModelHelper new];
            NSArray *docInfoArray = [model processDocumentTypesData:data];
            self.docInfoArray = docInfoArray;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.countryLabel.textColor = [UIColor blackColor];
                self.documentTypeLabel.enabled = YES;
                self.documentTypeLabel.textColor = [UIColor blackColor];
                self.documentTypeTextField.text = @"";
                self.documentTypeTextField.enabled = YES;
                [self.optionsTableView reloadData];
            });
        }
    }
}

- (void)connectionFailedWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                        message:NSLocalizedString(@"alert_msg_connection_error", @"Connection Error")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.status == EditingCountry) {
        return self.countriesArray.count;
    } else if(self.status == EditingDocType) {
        return self.docInfoArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *countryTableViewReuseID = @"simpleCellReuseID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:countryTableViewReuseID];
        cell.textLabel.font = [UIFont robotoWithSize:16.0];
        cell.textLabel.minimumScaleFactor = 12.0/16.0;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if(self.status == EditingCountry) {
    
        CountryDetails *data = self.countriesArray[indexPath.row];
        cell.textLabel.text = data.name;
        
    } else if(self.status == EditingDocType) {
        
        DocumentTypeDetails *data = self.docInfoArray[indexPath.row];
        cell.textLabel.text = data.name;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.status == EditingCountry) {
        
        [self.view endEditing:YES];
        
    } else if(self.status == EditingDocType) {
        self.selectedDocInfoIndex = indexPath.row;
        DocumentTypeDetails *data = self.docInfoArray[indexPath.row];
        self.documentTypeTextField.text = data.name;
        self.documentNumberLabel.textColor = [UIColor blackColor];
        self.documentNumberLabel.enabled = YES;
        self.documentNumberTextField.enabled = YES;
        
        self.docNumberExampleLabel.text = [NSString stringWithFormat:@"(%@)", data.mask];
        
        [self hideSelectionPanel];
    }
}

#pragma mark UITextField methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self turnOffTextFieldsHighlight];
    
    if(textField == self.countryTextField) {
        
        self.status = EditingCountry;
        [self.optionsTableView reloadData];
        [self searchCountry:self.countryTextField.text];
        
        [self showSelectionPanel];
        
        textField.layer.shadowColor = [UIColor appDarkColorWithOpacity:1.0].CGColor;
        
    } else if(textField == self.documentTypeTextField) {
        
        self.status = EditingDocType;
        [self.countryTextField endEditing:YES];
        [self.documentNumberTextField endEditing:YES];
        [self.optionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [self.optionsTableView reloadData];
        [self showSelectionPanel];
        
        textField.layer.shadowColor = [UIColor appDarkColorWithOpacity:1.0].CGColor;
        
        return NO;
        
    } else if(textField == self.documentNumberTextField) {
        
        [self hideSelectionPanel];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if(textField == self.countryTextField) {
        
        if(textField.text.length > 0) {
            [textField selectAll:self];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if(textField == self.countryTextField) {
        
        [self hideSelectionPanel];
        [self selectCountryAtIndex:self.optionsTableView.indexPathForSelectedRow.row];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField != self.countryTextField) {
        return YES;
    }
    
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self searchCountry:newText];
    
    return YES;
}

#pragma mark Keyboard events

- (void)keyboardWillShow {
    
    self.verticalCenterConstraint.constant = -160;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide {
    self.verticalCenterConstraint.constant = 0;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
