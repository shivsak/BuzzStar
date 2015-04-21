//
//  CustomerPayments.h
//  Buzzr
//
//  Created by Shiv Sakhuja on 3/7/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface CustomerPayments : ViewController <PKPaymentAuthorizationViewControllerDelegate> {
    
    IBOutlet UITextField *totalAmountTextField;
    IBOutlet UITextField *tipAmountTextField;
    IBOutlet UITextField *billAmountTextField;
    IBOutlet UIButton *doneButton;
}

@property (strong, nonatomic) NSString *customerPhone;
@property (strong, nonatomic) NSString *restaurantUsername;

@property (strong, nonatomic) NSString *paymentDescription;
@property (strong, nonatomic) NSString *paymentAmount;

@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSError *applePayError;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;

-(IBAction)confirmPayment:(id)sender;
- (IBAction)viewBill:(id)sender;
- (IBAction)autoAmount:(id)sender;
- (IBAction)tipPercent:(id)sender;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)keyboardAppeared:(id)sender;

@end
