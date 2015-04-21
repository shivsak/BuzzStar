//
//  CustomerViewController.h
//  Buzzr
//
//  Created by Shiv Sakhuja on 2/6/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import <SSKeychain/SSKeychain.h>
#import <MapKit/MapKit.h>

@interface CustomerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIView *signInView;
    IBOutlet UIView *signUpView;
    
    IBOutlet UITextField *firstNameTextField;
    IBOutlet UITextField *lastNameTextField;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *phoneTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    
    IBOutlet UITextField *phoneTextFieldSignIn;
    IBOutlet UITextField *passwordTextFieldSignIn;
    KeychainItemWrapper *keychainItem;
    
    IBOutlet UITableView *restaurantsTableView;
    IBOutlet UITableView *favoritesTableView;
    
    IBOutlet UIView *detailView;
    IBOutlet UILabel *detailRestaurantName;
    IBOutlet UILabel *detailRestaurantAddress;
    IBOutlet UILabel *detailRestaurantPhone;
    IBOutlet UILabel *detailRestaurantUsername;
    IBOutlet UIImageView *detailRestaurantImageView;
    
    IBOutlet UILabel *customerName;
    IBOutlet UIImageView *customerAvatar;
    
    IBOutlet UIButton *favoritesButton;
    IBOutlet UIButton *restaurantsButton;
    IBOutlet UIButton *logOutButton;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIView *overlayView;
    IBOutlet UIView *detailOverlayView;
    IBOutlet UIView *detailRestaurantImageOverlay;
    IBOutlet UIView *noRestaurantsView;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property BOOL isLoggedIn;
@property (nonatomic, retain) NSString *customerPhone;
@property (nonatomic, retain) NSMutableDictionary *customerInfo;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlMain;

@property (strong, nonatomic) NSMutableArray *queuedRestaurants;
@property (strong, nonatomic) NSMutableArray *favoriteRestaurants;
@property (strong, nonatomic) NSMutableDictionary *restaurantDictionary;

-(IBAction)signUp:(id)sender;
-(IBAction)signIn:(id)sender;

-(IBAction)showDetails:(id)sender;
-(IBAction)hideDetails:(id)sender;

-(IBAction)callRestaurant:(id)sender;
-(IBAction)openInMaps:(id)sender;

-(IBAction)returnKeyButton:(id)sender;

-(IBAction)logOut:(id)sender;

-(IBAction)backToFirstPage:(id)sender;

- (IBAction)showFavorites:(id)sender;
- (IBAction)showRestaurants:(id)sender;

@end
