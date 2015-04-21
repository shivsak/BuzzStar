//
//  CustomerPayments.m
//  Buzzr
//
//  Created by Shiv Sakhuja on 3/7/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "CustomerPayments.h"
#import "CustomerViewController.h"
#import "AppDelegate.h"
#import "Stripe.h"
#import "STPAPIClient.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"

@implementation CustomerPayments

@synthesize customerPhone, restaurantUsername, applePayButton, applePayError, applePaySucceeded;

static NSString * const APPLE_MERCHANT_ID = @"merchant.com.shiv.buzzr";
static NSString * const PAYMENTS_LINK = @"http://shivs-macbook-pro.local/buzzr/data/create_payment.php";

-(void)viewDidLoad {
    doneButton.hidden = YES;
    _paymentDescription = restaurantUsername;
}


//Display Bill (TableView?)
- (IBAction)viewBill:(id)sender {
}

//Automatically Fill Bill Amount
- (IBAction)autoAmount:(id)sender {
    
}

//Tip Percent
- (IBAction)tipPercent:(id)sender {
    if ([billAmountTextField.text length] == 0) {
        UIAlertView *billAmountEmptyAlert = [[UIAlertView alloc] initWithTitle:@"No Bill Amount!" message:@"Please enter the bill amount before choosing tip percentage." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [billAmountEmptyAlert show];
    }
    else {
        NSInteger percentTag = [sender tag];
        float billAmount = [billAmountTextField.text floatValue];
        float tipAmount = (billAmount * percentTag) / 100;
        float totalAmount = billAmount + tipAmount;
        tipAmountTextField.text = [NSString stringWithFormat:@"%.2f", tipAmount];
        totalAmountTextField.text = [NSString stringWithFormat:@"%.2f", totalAmount];
    }
}

-(IBAction)confirmPayment:(id)sender {
    _paymentDescription = restaurantUsername;
    self.applePaySucceeded = NO;
    self.applePayError = nil;
    
    PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:APPLE_MERCHANT_ID];
    // Configure your request here.
    
    //    NSDecimalNumber *amount1 = [NSDecimalNumber decimalNumberWithString:@"10.00"];
    //    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"Double Bacon Cheeseburger" amount:amount1];
    //
    //    NSDecimalNumber *amount2 = [NSDecimalNumber decimalNumberWithString:@"6.00"];
    //    PKPaymentSummaryItem *item2 = [PKPaymentSummaryItem summaryItemWithLabel:@"Oreo Milkshake" amount:amount2];
    
    float totalAmount = [totalAmountTextField.text floatValue];
    NSInteger requestTotalAmount = totalAmount * 100;
    NSDecimalNumber *decimalAmount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f", totalAmount]];
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Total Amount:" amount:decimalAmount];
    
    _paymentAmount = [NSString stringWithFormat:@"%li", requestTotalAmount];
    
    request.paymentSummaryItems = @[total];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
//#if DEBUG
//        STPTestPaymentAuthorizationViewController *auth = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
//#else
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
//#endif
        auth.delegate = self;
        [self presentViewController:auth animated:YES completion:nil];
    }
    
    else {
        // Show the user your own credit card form (see options 2 or 3)
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    NSLog(@"didAuthorPayment method ran");
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}



- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSLog(@"HandlePayment Method ran");
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                 /*
                                                  We'll implement this below in "Sending the token to your server".
                                                  Notice that we're passing the completion block through.
                                                  See the above comment in didAuthorizePayment to learn why.
                                                  */
                                                 NSLog(@"Passing CreateBackendCharge");
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:PAYMENTS_LINK];
    NSLog(@"Token ID: %@", token.tokenId);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@&description=%@&amount=%@", token.tokenId, _paymentDescription, _paymentAmount];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   completion(PKPaymentAuthorizationStatusFailure);
                               } else {
                                   completion(PKPaymentAuthorizationStatusSuccess);
                               }
                           }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    if (self.applePaySucceeded) {
        [self paymentSucceeded];
    } else {
        [self presentError:self.applePayError];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.applePaySucceeded = NO;
    self.applePayError = nil;
}

#pragma mark - Stripe Checkout


- (void)checkoutController:(STPCheckoutViewController *)controller didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
    switch (status) {
        case STPPaymentStatusSuccess:
            [self paymentSucceeded];
            break;
        case STPPaymentStatusError:
            [self presentError:error];
            break;
        case STPPaymentStatusUserCancelled:
            // do nothing
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)keyboardAppeared:(id)sender {
    doneButton.hidden = NO;
}

-(IBAction)doneButtonPressed:(id)sender {
    [billAmountTextField resignFirstResponder];
    [tipAmountTextField resignFirstResponder];
    [totalAmountTextField resignFirstResponder];
    doneButton.hidden = YES;
}


- (void)paymentSucceeded {
    [[[UIAlertView alloc] initWithTitle:@"Success!"
                                message:@"Payment successfully created!"
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)presentError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

@end
