//
//  RestaurantViewController.h
//  Buzzr
//
//  Created by Shiv Sakhuja on 2/6/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSKeychain/SSKeychain.h>

@interface RestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    IBOutlet UIView *signInView;
    IBOutlet UIView *signUpView;
    
    IBOutlet UITextField *restaurantNameTextField;
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *phoneTextField;
    IBOutlet UITextField *addressTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    
    IBOutlet UITextField *usernameTextFieldSignIn;
    IBOutlet UITextField *passwordTextFieldSignIn;

    
    IBOutlet UITableView *tableView;
    
    IBOutlet UIView *detailView;
    IBOutlet UILabel *detailCustomerName;
    IBOutlet UILabel *detailCustomerEmail;
    IBOutlet UILabel *detailCustomerPhone;
    IBOutlet UILabel *detailCustomerSeats;
    IBOutlet UIImageView *detailCustomerImageView;
    
    IBOutlet UIView *addView;
    IBOutlet UITextField *addPhone;
    IBOutlet UITextField *addName;
    IBOutlet UIPickerView *addSeats;
    IBOutlet UIButton *addButton;
    
    IBOutlet UILabel *restaurantName;
    IBOutlet UIImageView *restaurantAvatar;
    IBOutlet UIImageView *restaurantCover;
    
    IBOutlet UIButton *logOutButton;
    
    IBOutlet UILabel *totalWaitingLabel;
    IBOutlet UIView *detailCardView;
    IBOutlet UIView *bodyView;
}

@property BOOL isLoggedIn;
@property (nonatomic, retain) NSString *restaurantUsername;
@property (nonatomic, retain) NSMutableDictionary *restaurantInfo;

@property (strong, nonatomic) NSMutableArray *queuedCustomers;
@property (strong, nonatomic) NSMutableDictionary *customerDictionary;

@property (strong, nonatomic) NSArray *seatsPickerArray;

@property (nonatomic, retain) NSString *selectedRow;

-(IBAction)signUp:(id)sender;
-(IBAction)signIn:(id)sender;

-(IBAction)showDetails:(id)sender;
-(IBAction)hideDetails:(id)sender;

-(IBAction)callCustomer:(id)sender;

-(IBAction)returnKeyButton:(id)sender;

-(IBAction)logOut:(id)sender;

-(IBAction)addToWaitlist:(id)sender;
-(IBAction)cancelAdding:(id)sender;
-(IBAction)doneAdding:(id)sender;

-(IBAction)seat:(id)sender;
-(IBAction)remove:(id)sender;

@end
