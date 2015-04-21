//
//  ViewController.m
//  Buzzr
//
//  Created by Shiv Sakhuja on 2/6/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "ViewController.h"
#import <SSKeychain/SSKeychain.h>
#import "CustomerViewController.h"
#import "RestaurantViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize userType;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

-(void)viewDidAppear:(BOOL)animated {
    NSArray *customerKeychainArray = [SSKeychain accountsForService:@"customerLogin"];
    NSArray *restaurantKeychainArray = [SSKeychain accountsForService:@"restaurantLogin"];
    
    if ([customerKeychainArray count] > 0) {
        //User is customer with saved login
        NSLog(@"User is a customer");
        userType = @"customer";
    }
    if ([restaurantKeychainArray count] > 0) {
        //User is restaurant with saved login
        NSLog(@"User is a restaurant");
        userType = @"restaurant";
    }
    if ([restaurantKeychainArray count] > 0 && [customerKeychainArray count] > 0) {
        //User has both customer and restaurant logins
        NSLog(@"User has customer and restaurant logins");
        userType = @"both";
    }
    
    if ([userType isEqualToString:@"both"]) {
        //Do Nothing
    }
    else if ([userType isEqualToString:@"customer"]) {
        //Move to CustomerVC
        
        NSLog(@"Present customerVC");
        [self performSegueWithIdentifier:@"moveToCustomer" sender:self];
    }
    else if ([userType isEqualToString:@"restaurant"]) {
        //Move to RestaurantVC
        [self performSegueWithIdentifier:@"moveToRestaurant" sender:self];
    }
    else {
        //Do Nothing
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
