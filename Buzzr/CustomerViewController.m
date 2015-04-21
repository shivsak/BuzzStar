//
//  CustomerViewController.m
//  Buzzr
//

//  Created by Shiv Sakhuja on 2/6/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "CustomerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Security/Security.h>
#import "AFHTTPSessionManager.h"
#import "CustomCell.h"
#import <POP/POP.h>
#import "SVPullToRefresh.h"
#import "ILTranslucentView.h"
#import "SVGeocoder/SVGeocoder.h"

@implementation CustomerViewController

static NSString * const root_address = @"http://shivs-macbook-pro.local/buzzr/data/";

@synthesize isLoggedIn, queuedRestaurants, customerPhone, restaurantDictionary, customerInfo, favoriteRestaurants, mapView;

-(void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.mapView.delegate = self;
    
    passwordTextField.secureTextEntry = YES;
    confirmPasswordTextField.secureTextEntry = YES;
    passwordTextFieldSignIn.secureTextEntry = YES;
    
    //Initialize Arrays
    self.favoriteRestaurants = [[NSMutableArray alloc] init];
    
    //KeyChain
    NSArray *keychainArray = [SSKeychain accountsForService:@"customerLogin"];
    if ([keychainArray count] > 0) {
        NSString *savedPhone = [keychainArray[0] objectForKey:@"acct"];
        NSString *savedPassword = [SSKeychain passwordForService:@"customerLogin" account:savedPhone];
        [self sendSignInRequest:savedPhone forPassword:savedPassword];
        NSLog(@"Saved Phone: %@", savedPhone);
        NSLog(@"Saved Password: %@", savedPassword);
    }
    else {
        phoneTextFieldSignIn.text = @"9174680485";
        passwordTextFieldSignIn.text = @"alalal";
    }
    
    [self initialView];
    
}

-(void)initialView {
    //Blur Background
//    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 210, self.view.frame.size.width, (self.view.frame.size.height - 210))];
//    [overlayView addSubview:translucentView]; //that's it :)
//    
//    translucentView.translucentAlpha = 0.4;
//    translucentView.translucentStyle = UIBarStyleDefault;
//    translucentView.translucentTintColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.85];
//    translucentView.backgroundColor = [UIColor clearColor];
    
    [restaurantsTableView.pullToRefreshView setArrowColor:[UIColor whiteColor]];
    restaurantsTableView.pullToRefreshView.textColor = [UIColor whiteColor];
    [restaurantsTableView.pullToRefreshView setTitle:@"Pull Me!" forState:SVPullToRefreshStateAll];
    
    [restaurantsTableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        [self getConsumerData];
        [restaurantsTableView.pullToRefreshView stopAnimating];
    }];
    
    
    [favoritesTableView.pullToRefreshView setArrowColor:[UIColor whiteColor]];
    favoritesTableView.pullToRefreshView.textColor = [UIColor whiteColor];
    [favoritesTableView.pullToRefreshView setTitle:@"Pull Me!" forState:SVPullToRefreshStateAll];
    
    [favoritesTableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        [self getFavoritesData];
        [favoritesTableView.pullToRefreshView stopAnimating];
    }];
    
    
}

-(IBAction)returnKeyButton:(id)sender {
    
    [sender resignFirstResponder];
    
}


-(IBAction)signUp:(id)sender {
    BOOL isFirstNameValid = (firstNameTextField.text.length > 0);
    BOOL isLastNameValid = (lastNameTextField.text.length > 0);
    BOOL isEmailInvalid = ([emailTextField.text rangeOfString:@"@"].location == NSNotFound);
    BOOL isPhoneValid = (phoneTextField.text.length == 10);
    BOOL isPasswordLengthValid = (passwordTextField.text.length >=6);     //password length
    BOOL passwordAndConfirm = ([passwordTextField.text isEqualToString:confirmPasswordTextField.text]); //password, confirmPass
    
    
    if (isFirstNameValid != true) {
        UIAlertView *firstNameAlert = [[UIAlertView alloc] initWithTitle:@"No First Name" message:@"You must enter a First Name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [firstNameAlert show];
        
        firstNameTextField.text = @"";
    }
    
    else if (isLastNameValid != true) {
        UIAlertView *lastNameAlert = [[UIAlertView alloc] initWithTitle:@"No Last Name" message:@"You must enter a Last Name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [lastNameAlert show];
        
        lastNameTextField.text = @"";
    }
    
    else if (isEmailInvalid) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidEmailAlert show];
        
        emailTextField.text = @"";
    }
    
    else if (isPhoneValid != true) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Please enter a valid US phone number (10 Digits)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidEmailAlert show];
        
        phoneTextField.text = @"";
    }
    
    else if (isPasswordLengthValid != true) {
        UIAlertView *invalidPasswordLengthAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"Your password must be between 6 and 25 characters (inclusive)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidPasswordLengthAlert show];
        
        passwordTextField.text = @"";
        confirmPasswordTextField.text = @"";
    }
    
    else if (passwordAndConfirm != true) {
        //Password and Confirm Password do not match
        UIAlertView *passwordMatchAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"Your passwords do not match!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [passwordMatchAlert show];
        
        passwordTextField.text = @"";
        confirmPasswordTextField.text = @"";
    }
    
    else {
        [self sendSignUpRequest];
    }
}

-(void)sendSignUpRequest {
    
    NSString *post = [NSString stringWithFormat:@"email=%@&password=%@&phone=%@&first_name=%@&last_name=%@&credit=%@",emailTextField.text, passwordTextField.text, phoneTextField.text, firstNameTextField.text, lastNameTextField.text, @"-99"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@consumer_register.php", root_address]];
    NSError *error;
    NSData *data = [self sendPostRequest:post forURL:url];
    
    //Check If Sign Up Was Successful
}


-(IBAction)signIn:(id)sender {
    BOOL isPhoneValid = (phoneTextFieldSignIn.text.length == 10);
    
    if (isPhoneValid != true) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Please enter a valid US phone number (10 Digits)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidEmailAlert show];
        
        phoneTextFieldSignIn.text = @"";
    }
    
    [self sendSignInRequest:phoneTextFieldSignIn.text forPassword:passwordTextFieldSignIn.text];
    
}

-(void)sendSignInRequest:(NSString *)phone forPassword:(NSString *)password {
    
    NSString *post = [NSString stringWithFormat:@"phone=%@&password=%@",phone, password];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@consumer_login.php", root_address]];
    NSError *error;
    NSData *data = [self sendPostRequest:post forURL:url];
    
    
    // Make synchronous request
    
    NSString *resultDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Sign In Result: %@", resultDataString);
    
    if ([resultDataString isEqualToString:@"\"success\""]) {
        //Logged In
        isLoggedIn = true;
        self.customerPhone = phone;
        NSString *enteredPassword = password;
        [SSKeychain setPassword:enteredPassword forService:@"customerLogin" account:phone];
        
        [self loggedIn:isLoggedIn];
        
    }
    else {
        isLoggedIn = false;
        UIAlertView *incorrectCombinationAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect Phone / Password" message:@"Incorrect Phone Number and Password Combination! Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [incorrectCombinationAlert show];
        
        //        phoneTextFieldSignIn.text = @"";
        passwordTextFieldSignIn.text = @"";
    }
    
    
}

-(void)loggedIn:(BOOL)isLoggedIn {
    signInView.hidden = isLoggedIn;
    [self getConsumerData];
    [self getFavoritesData];
    NSString *customerFirstName = [customerInfo objectForKey:@"first_name"];
    NSString *customerLastName = [customerInfo objectForKey:@"last_name"];
    NSString *customerEmail = [customerInfo objectForKey:@"email"];
    NSString *customerCredits = [customerInfo objectForKey:@"credits"];
    NSString *customerImagePath = [customerInfo objectForKey:@"image_path1"];
    
    customerName.text = [NSString stringWithFormat:@"%@ %@", customerFirstName, customerLastName];
    if (customerImagePath.length > 0) {
        customerAvatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:customerImagePath]]];
    }
    else {
        customerAvatar.image = [UIImage imageNamed:@"default-customer.jpg"];
    }
    
}


//No of sections in Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == restaurantsTableView) {
        return [self.queuedRestaurants count];
    }
    else {
        return [self.favoriteRestaurants count];
    }
    
}

//No of rows in the Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 7; //Cell Spacing
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier1 = @"CellRest";
    static NSString *CellIdentifier2 = @"CellFav";
    
    CustomCell *cell;
    
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
    }
    
    cell.layer.shadowColor = [[UIColor grayColor] CGColor];
    cell.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.shadowRadius = 2.0f;
    cell.layer.masksToBounds = NO;
    
    
    if (tableView == restaurantsTableView) {
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[CustomCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier1];
        }

        NSDictionary *dictionary = [self.queuedRestaurants objectAtIndex:indexPath.section];
        NSString *realName = [dictionary objectForKey:@"real_name"];
        NSString *address = [dictionary objectForKey:@"address"];
        NSString *credits = [dictionary objectForKey:@"credits"];
        NSString *description = [dictionary objectForKey:@"description"];
        NSString *phoneNumber = [dictionary objectForKey:@"phone_number"];
        NSString *waitingFront = [[dictionary objectForKey:@"waiting_front"] stringValue];
        NSString *username = [dictionary objectForKey:@"user_name"];
        NSString *imagePath1 = [dictionary objectForKey:@"image_path1"];
        NSString *imagePath2 = [dictionary objectForKey:@"image_path2"];
        
        NSLog(@"Waiting: %@", waitingFront);
        cell.cellRestaurantName.text = realName;
        cell.cellQueue.text = waitingFront;
        cell.cellRestaurantUsername = username;
        cell.cellRestaurantAddress = address;
        cell.cellRestaurantRealName = realName;
        cell.cellRestaurantUsername = username;
        
        NSString *phoneArea = [phoneNumber substringToIndex:3];
        NSString *phoneMiddle = [phoneNumber substringWithRange:NSMakeRange(3, 3)];
        NSString *phoneEnd = [phoneNumber substringFromIndex:6];
        cell.cellRestaurantPhone = phoneNumber;
        cell.cellRestaurantPhoneNumber.text = [NSString stringWithFormat:@"(%@) %@-%@", phoneArea, phoneMiddle, phoneEnd];
        
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:0.2 green:0.5 blue:1 alpha:1];
        cell.selectedBackgroundView = selectionColor;
        
        return cell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[CustomCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier2];
        }
        NSDictionary *dictionary = [self.favoriteRestaurants objectAtIndex:indexPath.section];
        
        NSString *realName = [dictionary objectForKey:@"real_name"];
        NSString *address = [dictionary objectForKey:@"address"];
        NSString *credits = [dictionary objectForKey:@"credits"];
        NSString *description = [dictionary objectForKey:@"description"];
        NSString *phoneNumber = [dictionary objectForKey:@"phone_number"];
        NSString *waitingFront = [[dictionary objectForKey:@"waiting_front"] stringValue];
        NSString *username = [dictionary objectForKey:@"user_name"];
        NSString *imagePath1 = [dictionary objectForKey:@"image_path1"];
        NSString *imagePath2 = [dictionary objectForKey:@"image_path2"];
        
        cell.cellRestaurantName.text = realName;
        cell.cellQueue.text = waitingFront;
        cell.cellRestaurantUsername = username;
        cell.cellRestaurantAddress = address;
        cell.cellRestaurantRealName = realName;
        cell.cellRestaurantUsername = username;
        
        NSString *phoneArea = [phoneNumber substringToIndex:3];
        NSString *phoneMiddle = [phoneNumber substringWithRange:NSMakeRange(3, 3)];
        NSString *phoneEnd = [phoneNumber substringFromIndex:6];
        cell.cellRestaurantPhone = phoneNumber;
        cell.cellRestaurantPhoneNumber.text = [NSString stringWithFormat:@"(%@) %@-%@", phoneArea, phoneMiddle, phoneEnd];
        
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:(138/255.0) green:(0/255.0) blue:(235/255.0) alpha:1];
        cell.selectedBackgroundView = selectionColor;
        
        return cell;
        
    }
}

-(void)showDetails:(NSIndexPath *)indexPath forTable:(UITableView *)tableView {
    
    CustomCell *cell;
    
    if (tableView == restaurantsTableView) {
        cell = [restaurantsTableView cellForRowAtIndexPath:indexPath];
    }
    else {
        cell = [favoritesTableView cellForRowAtIndexPath:indexPath];
    }
    
    detailRestaurantName.text = cell.cellRestaurantRealName;
    detailRestaurantPhone.text = cell.cellRestaurantPhone;
    detailRestaurantAddress.text = cell.cellRestaurantAddress;
    detailRestaurantUsername.text = [NSString stringWithFormat:@"@%@", cell.cellRestaurantUsername];
    if (cell.cellRestaurantImagePath1 != NULL) {
        detailRestaurantImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:cell.cellRestaurantImagePath1]]];
    }
    else {
        detailRestaurantImageView.image = [UIImage imageNamed:@"food1.jpg"];
    }
    
    NSLog(@"%@", cell.cellRestaurantAddress);
    NSLog(@"%@", cell.cellRestaurantPhone);
    NSLog(@"%@", cell.cellRestaurantUsername);
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(self.view.frame.size.height/2);
    anim.springBounciness = 10;
    anim.springSpeed = 1.2;
    anim.dynamicsFriction = 14.0;
    [detailView pop_addAnimation:anim forKey:@"slide"];
    
}


-(IBAction)hideDetails:(id)sender {
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(2*self.view.frame.size.height);
    anim.springBounciness = 0;
    anim.springSpeed = 1.2;
    anim.dynamicsFriction = 40.0;
    [detailView pop_addAnimation:anim forKey:@"slide"];
}

-(IBAction)callRestaurant:(id)sender {
    NSLog(@"Call Restaurant");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", detailRestaurantPhone]]];
}

-(IBAction)openInMaps:(id)sender {
    NSLog(@"Open in Maps");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@", detailRestaurantAddress]]];
}


//Allow Deleting
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == restaurantsTableView) {
        UITableViewRowAction *leaveButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Leave Waitlist" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                             {
                                                 [self leaveWaitlist:indexPath];
                                             }];
        leaveButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.3 alpha:1.0]; //arbitrary color
        
        UITableViewRowAction *favoritesButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                                 {
                                                     [self addToFavorites:indexPath];
                                                 }];
        favoritesButton.backgroundColor = [UIColor colorWithRed:0.7 green:0.3 blue:0.8 alpha:1.0]; //arbitrary color
        
        return @[leaveButton, favoritesButton];
    }
    else {
        UITableViewRowAction *removeButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Leave Waitlist" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                              {
                                                  [self removeFavorite:indexPath];
                                              }];
        removeButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.3 alpha:1.0]; //red color
        
        
        UITableViewRowAction *joinButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                            {
                                                [self joinWaitlist:indexPath];
                                            }];
        joinButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0]; //arbitrary color
        
        return @[removeButton, joinButton];
        
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // you need to implement this method too or nothing will work:
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)leaveWaitlist:(NSIndexPath *)indexPath {
    NSString *userName = [[self.queuedRestaurants objectAtIndex:indexPath.section] objectForKey:@"user_name"];
    //Remove Customer From Actual Waitlist
    NSString *post = [NSString stringWithFormat:@"customer_phone=%@&restaurant_username=%@", self.customerPhone, userName];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@consumer_leave_waitlist.php", root_address]];
    NSData *data = [self sendPostRequest:post forURL:url];
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([result isEqualToString:@"success"]) {
        UIAlertView *leftWaitlistAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully left the waitlist." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [leftWaitlistAlert show];
    }
    else {
        UIAlertView *leftWaitlistAlert = [[UIAlertView alloc] initWithTitle:@"Failed!" message:@"Failed to remove you from the waitlist. Please Try Again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [leftWaitlistAlert show];
    }
    [self getConsumerData];
}


-(void)addToFavorites:(NSIndexPath *)indexPath {
    NSString *restaurant_username = [[self.queuedRestaurants objectAtIndex:indexPath.section] objectForKey:@"user_name"];
    NSString *post = [NSString stringWithFormat:@"customer_phone=%@&restaurant_username=%@",customerPhone, restaurant_username];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@consumer_add_favorites.php", root_address]];
    
    [self getFavoritesData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Selected row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showDetails:indexPath forTable:tableView];
}


-(void)getConsumerData {
    
    if (![self isInternetConnection]) {
        //No Internet
    }
    
    else if (self.customerPhone == NULL) {
        NSLog(@"Phone Number is null");
    }
    
    else {
        NSString *post = [NSString stringWithFormat:@"consumer_phone_number=%@", self.customerPhone];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@consumer_restaurant_front.php", root_address]];
        NSError *error;
        NSData *data = [self sendPostRequest:post forURL:url];
        
        
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        self.customerInfo = [[jsonData objectAtIndex:0] mutableCopy];
        
        self.queuedRestaurants = [[jsonData objectAtIndex:1] mutableCopy];
        NSLog(@"Queued Restaurants: %@", self.queuedRestaurants);
        
        if ([self.queuedRestaurants count] < 1) {
            noRestaurantsView.hidden = NO;
        }
        else {
            noRestaurantsView.hidden = YES;
        }
        
        [restaurantsTableView reloadData];
    }
}

-(void)showNoInternetMessage {
    UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"You do not have an active internet connection. Please connect to the internet and try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [noInternetAlert show];
}


-(void)reloadTable:(UITableView*)tableView {
    [tableView reloadData];
}

-(IBAction)logOut:(id)sender {
    [SSKeychain deletePasswordForService:@"customerLogin" account:self.customerPhone];
    self.customerPhone = @"";
    [self.queuedRestaurants removeAllObjects];
    [self.customerInfo removeAllObjects];
    
    [restaurantsTableView reloadData];
    signInView.hidden = NO;
    
    [self performSegueWithIdentifier:@"backToInitial" sender:self];
    
}

-(void)updatePage:(int)page {
    
}

- (IBAction)showFavorites:(id)sender {
    POPSpringAnimation *showFavoritesAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    showFavoritesAnim.toValue = @(self.view.frame.size.width/2);
    showFavoritesAnim.springBounciness = 10;
    showFavoritesAnim.springSpeed = 1.2;
    showFavoritesAnim.dynamicsFriction = 14.0;
    [favoritesTableView pop_addAnimation:showFavoritesAnim forKey:@"slide"];
    
    POPSpringAnimation *hideRestaurantsAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    hideRestaurantsAnim.toValue = @(-3*self.view.frame.size.width/2);
    hideRestaurantsAnim.springBounciness = 10;
    hideRestaurantsAnim.springSpeed = 1.2;
    hideRestaurantsAnim.dynamicsFriction = 14.0;
    [restaurantsTableView pop_addAnimation:hideRestaurantsAnim forKey:@"slide"];
    
    favoritesButton.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.4 alpha:0.75]; /*#ff3366*/
    [favoritesButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] forState:UIControlStateNormal];
    
    restaurantsButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [restaurantsButton.titleLabel setTextColor:[UIColor colorWithRed:1 green:0.2 blue:0.4 alpha:0.75]]; /*#ff3366*/
    
}

- (IBAction)showRestaurants:(id)sender {
    
    POPSpringAnimation *hideFavoritesAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    hideFavoritesAnim.toValue = @(3*self.view.frame.size.width/2);
    hideFavoritesAnim.springBounciness = 10;
    hideFavoritesAnim.springSpeed = 1.2;
    hideFavoritesAnim.dynamicsFriction = 14.0;
    [favoritesTableView pop_addAnimation:hideFavoritesAnim forKey:@"slide"];
    
    POPSpringAnimation *showRestaurantsAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    showRestaurantsAnim.toValue = @(self.view.frame.size.width/2);
    showRestaurantsAnim.springBounciness = 10;
    showRestaurantsAnim.springSpeed = 1.2;
    showRestaurantsAnim.dynamicsFriction = 14.0;
    [restaurantsTableView pop_addAnimation:showRestaurantsAnim forKey:@"slide"];
    
    restaurantsButton.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.4 alpha:0.75]; /*#ff3366*/
    [restaurantsButton.titleLabel setTextColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
    
    favoritesButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [favoritesButton.titleLabel setTextColor:[UIColor colorWithRed:1 green:0.2 blue:0.4 alpha:0.75]]; /*#ff3366*/
    
    [self getConsumerData];
}

-(void)getFavoritesData {
    [self.favoriteRestaurants removeAllObjects];
    
    if (![self isInternetConnection]) {
        //No Internet
    }
    
    else if (self.customerPhone == NULL) {
        NSLog(@"Phone is null");
    }
    
    else {
        NSString *post = [NSString stringWithFormat:@"customer_phone=%@", self.customerPhone];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@consumer_favorites.php", root_address]];
        NSError *error;
        NSData *data = [self sendPostRequest:post forURL:url];
        
        NSDictionary *favoritesData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        [self.favoriteRestaurants addObject:favoritesData];
        NSLog(@"favoriteRestaurants: %@", favoritesData);
        
        NSLog(@"%@", self.favoriteRestaurants);
        [self reloadTable:favoritesTableView];
    }
}

-(void)removeFavorite:(NSIndexPath *)indexPath {
    
}

-(void)joinWaitlist:(NSIndexPath *)indexPath {
    
}

-(BOOL)isInternetConnection {
    //   Check for Internet Connection
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.apple.com"]] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"%@", connect);
    if (connect == NULL) {
        //No Internet Connection
        [self showNoInternetMessage];
        return FALSE;
    }
    else {
        return TRUE;
    }
    
}

-(NSData *)sendPostRequest:post forURL:url {
    if (![self isInternetConnection]) {
        //No Internet Connection
        NSData *data = [[NSData alloc] init];
        return data;
    }
    else {
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:url]; //URL Here
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        
        // Setting a timeout
        [request setTimeoutInterval: 20.0];
        
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        NSLog(@"%@", post);
        
        if(conn) {
            NSLog(@"Favorites Connection Successful – Consumer Restaurant Front");
            
        } else {
            NSLog(@"Favorites Connection could not be made");
        }
        
        // Fetch the JSON response
        NSData *urlData;
        NSURLResponse *response;
        NSError *error;
        
        // Make synchronous request
        urlData = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&response
                                                    error:&error];
        
        // Construct a String around the Data from the response
        NSString *resultDataString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", resultDataString);
        
        return urlData;
    }
}


@end
