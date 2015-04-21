//
//  RestaurantViewController.m
//  Buzzr
//
//  Created by Shiv Sakhuja on 2/6/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//


#import "RestaurantViewController.h"
#import <Security/Security.h>
#import "AFHTTPSessionManager.h"
#import "RestaurantCell.h"
#import <POP/POP.h>


@implementation RestaurantViewController

NSIndexPath *selectedRow;

@synthesize isLoggedIn, queuedCustomers, restaurantUsername, customerDictionary, restaurantInfo, seatsPickerArray;

-(void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    passwordTextField.secureTextEntry = YES;
    confirmPasswordTextField.secureTextEntry = YES;
    passwordTextFieldSignIn.secureTextEntry = YES;
    
    self.seatsPickerArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    
    NSArray *keychainArray = [SSKeychain accountsForService:@"restaurantLogin"];
    if ([keychainArray count] > 0) {
        NSString *savedUsername = [keychainArray[0] objectForKey:@"acct"];
        NSString *savedPassword = [SSKeychain passwordForService:@"restaurantLogin" account:savedUsername];
        [self sendSignInRequest:savedUsername forPassword:savedPassword];
        NSLog(@"Saved Phone: %@", savedUsername);
        NSLog(@"Saved Password: %@", savedPassword);
    }
    else {
        usernameTextFieldSignIn.text = @"jacobp";
        passwordTextFieldSignIn.text = @"qpqpqp";
    }
    [self initialView];
}

-(void)initialView {
    if (isLoggedIn) {
        signInView.hidden = YES;
    }
    else {
        //User is not logged in
        signInView.hidden = NO;
    }
    
    [self hideDetails:nil];
//    detailCardView.layer.shadowColor = [[UIColor grayColor] CGColor];
//    detailCardView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
//    detailCardView.layer.shadowOpacity = 1.0f;
//    detailCardView.layer.shadowRadius = 2.0f;
//    detailCardView.layer.masksToBounds = NO;
}

-(IBAction)returnKeyButton:(id)sender {
    
    [sender resignFirstResponder];
    
}


-(IBAction)signUp:(id)sender {
    BOOL isRestaurantNameValid = (restaurantNameTextField.text.length > 0);
    BOOL isUsernameValid = (usernameTextField.text.length > 0);
    BOOL isEmailInvalid = ([emailTextField.text rangeOfString:@"@"].location == NSNotFound);
    BOOL isPhoneValid = (phoneTextField.text.length == 10);
    BOOL isPasswordLengthValid = (passwordTextField.text.length >=6);     //password length
    BOOL passwordAndConfirm = ([passwordTextField.text isEqualToString:confirmPasswordTextField.text]); //password, confirmPass
    
    
    if (isRestaurantNameValid != true) {
        UIAlertView *restaurantNameAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Name" message:@"You must enter a valid Restaurant Name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [restaurantNameAlert show];
        
        restaurantNameTextField.text = @"";
    }
    
    else if (isUsernameValid != true) {
        UIAlertView *usernameAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:@"You must enter a valid username (Letters and Numbers only)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [usernameAlert show];
        
        usernameTextField.text = @"";
    }
    
    else if ([usernameTextField.text rangeOfString:@" "].location == NSNotFound) {
        UIAlertView *usernameAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:@"Username may not contain spaces" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [usernameAlert show];
        
        usernameTextField.text = @"";
    }
    
    else if (isEmailInvalid) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidEmailAlert show];
        
        emailTextField.text = @"";
    }
    
    else if (isPhoneValid != true) {
        UIAlertView *invalidPhoneAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Please enter a valid US phone number (10 Digits)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidPhoneAlert show];
        
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
    
    NSString *post = [NSString stringWithFormat:@"email=%@&password=%@&phone=%@&real_name=%@&user_name=%@&credit=%@",emailTextField.text, passwordTextField.text, phoneTextField.text, restaurantNameTextField.text, usernameTextField.text, @"-99"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shivs-macbook-pro.local/buzzr/data/restaurant_register.php"]]]; //URL Here
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    // Setting a timeout
    [request setTimeoutInterval: 20.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    NSLog(@"%@", post);
    
    if(conn) {
        NSLog(@"Connection Successful");
        [self performSegueWithIdentifier:@"rMoveToSignIn" sender:nil];
        
    } else {
        NSLog(@"Connection could not be made");
    }
    
    
}


-(IBAction)signIn:(id)sender {
    
    [self sendSignInRequest:usernameTextFieldSignIn.text forPassword:passwordTextFieldSignIn.text];
    
}

-(void)sendSignInRequest:(NSString *)username forPassword:(NSString *)password {
    //Send PHP Request for Sign In
    
    //If Sign In is successful, save to Keychain
    
    NSString *post = [NSString stringWithFormat:@"user_name=%@&password=%@",username, password];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shivs-macbook-pro.local/buzzr/data/restaurant_login.php"]]]; //URL Here
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    // Setting a timeout
    [request setTimeoutInterval: 20.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    NSLog(@"%@", post);
    
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
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
    
    if ([resultDataString isEqualToString:@"\"success\""]) {
        //Logged In
        isLoggedIn = true;
        self.restaurantUsername = username;
        NSString *enteredPassword = password;
        [SSKeychain setPassword:enteredPassword forService:@"restaurantLogin" account:username];
        
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
    [self getRestaurantData];
    
    NSString *restaurantRealName = [restaurantInfo objectForKey:@"real_name"];
    NSString *restaurantUsername = [restaurantInfo objectForKey:@"user_name"];
    NSString *restaurantEmail = [restaurantInfo objectForKey:@"email"];
    NSString *restaurantCredits = [restaurantInfo objectForKey:@"credits"];
    NSString *restaurantImagePath1 = [restaurantInfo objectForKey:@"image_path1"];
    NSString *restaurantImagePath2 = [restaurantInfo objectForKey:@"image_path2"];
    NSString *restaurantTotalWaiting = [[restaurantInfo objectForKey:@"total_waiting"] stringValue];
    
    restaurantName.text = restaurantRealName;
    
    //Avatar Image
    if (restaurantImagePath1.length > 0) {
        restaurantAvatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:restaurantImagePath1]]];
    }
    else {
        restaurantAvatar.image = [UIImage imageNamed:@"default-avatar.jpg"];
    }
    
    //Cover Image
    if (restaurantImagePath2.length > 0) {
        restaurantCover.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:restaurantImagePath2]]];
    }
    else {
        restaurantCover.image = [UIImage imageNamed:@"default-cover.jpg"];
    }
    
    totalWaitingLabel.text = [NSString stringWithFormat:@"%@ Customers Waiting", restaurantTotalWaiting];
    
}


//No of sections in Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.queuedCustomers count];;
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
    
    NSDictionary *dictionary = [self.queuedCustomers objectAtIndex:indexPath.section];
    NSString *firstName = [dictionary objectForKey:@"first_name"];
    NSString *lastName = [dictionary objectForKey:@"last_name"];
    NSString *email = [dictionary objectForKey:@"email"];
    NSString *credits = [dictionary objectForKey:@"credits"];
    NSString *description = [dictionary objectForKey:@"description"];
    NSString *phoneNumber = [dictionary objectForKey:@"phone"];
    NSString *seats = [dictionary objectForKey:@"seats"];
    NSString *username = [dictionary objectForKey:@"user_name"];
    NSString *imagePath1 = [dictionary objectForKey:@"image_path1"];
    NSString *imagePath2 = [dictionary objectForKey:@"image_path2"];
    NSString *enteredCustomerName = [dictionary objectForKey:@"customer_name"];
    
    static NSString *simpleIdentifier = @"rCell";
    
    RestaurantCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    if (cell == nil) {
        cell = [[RestaurantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    
    NSLog(@"Seats: %@", seats);
    NSLog(@"Name: %@ %@", firstName, lastName);
    NSLog(@"Phone: %@", phoneNumber);
    
    
    if (firstName == NULL && lastName == NULL && ![enteredCustomerName isEqualToString:@""]) {
        cell.customerName = enteredCustomerName;
    }
    else if (firstName == NULL && lastName == NULL && [enteredCustomerName isEqualToString:@""]) {
        cell.customerName = @"Unknown";
    }
    else {
        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        cell.customerName = name;
    }
    
    cell.cellCustomerTableFor.text = seats;
    cell.customerImageName = imagePath1;
    cell.cellCustomerName.text = cell.customerName;
    cell.customerEmail = email;
    
    if (phoneNumber.length > 0) {
////        NSString *phoneArea = [phoneNumber substringToIndex:3];
////        NSString *phoneMiddle = [phoneNumber substringWithRange:NSMakeRange(3, 3)];
////        NSString *phoneEnd = [phoneNumber substringFromIndex:6];
        cell.customerPhone = [NSString stringWithFormat:@"%@", phoneNumber];
//        cell.cellCustomerPhoneNumber.text = [NSString stringWithFormat:@"(%@) %@-%@", phoneArea, phoneMiddle, phoneEnd];
        cell.cellCustomerPhoneNumber.text = cell.customerPhone;
        
    }
    else {
        cell.customerPhone = @"Unknown";
        cell.cellCustomerPhoneNumber.text = @"Unknown";
    }
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(202/255.0) green:(202/255.0) blue:(202/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

-(void)showDetails:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    detailCustomerName.text = cell.cellCustomerName.text;
    detailCustomerPhone.text = cell.cellCustomerPhoneNumber.text;
    detailCustomerSeats.text = cell.cellCustomerTableFor.text;
    
    if (cell.customerEmail != NULL) {
        detailCustomerEmail.text = cell.customerEmail;
    }
    else {
        detailCustomerEmail.text = @"Unknown";
    }
    
//    if (cell.customerImageName != NULL) {
//        detailCustomerImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:cell.customerImageName]]];
//    }
//    else {
        detailCustomerImageView.image = [UIImage imageNamed:@"default-customer-avatar.jpg"];
//    }
    
    POPBasicAnimation *fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeIn.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    fadeIn.toValue = @(1.0);
    fadeIn.duration = 0.5;
    [detailView pop_addAnimation:fadeIn forKey:@"fadeDetailsIn"];
}


-(IBAction)hideDetails:(id)sender {
    
    POPBasicAnimation *fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeOut.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    fadeOut.toValue = @(0.0);
    fadeOut.duration = 0.5;
    [detailView pop_addAnimation:fadeOut forKey:@"fadeDetailsOut"];
}

-(IBAction)callCustomer:(id)sender {
    
    NSLog(@"Call Restaurant");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", detailCustomerPhone]]];
}


//Custom Cell Actions
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *seatButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Seat Customer" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                         {
                                             [self seatCustomer:indexPath];
                                         }];
    seatButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0]; //arbitrary color
    
    UITableViewRowAction *removeButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                             {
                                                 [self removeFromWaitlist:indexPath];
                                             }];
    removeButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0]; //arbitrary color
    
    return @[removeButton, seatButton];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // you need to implement this method too or nothing will work:
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(IBAction)seat:(id)sender {
    [self seatCustomer:selectedRow];
}
-(IBAction)remove:(id)sender {
    [self removeFromWaitlist:selectedRow];
}

-(void)removeFromWaitlist:(NSIndexPath *)indexPath {
    NSDictionary *tempDictionary = [self.queuedCustomers objectAtIndex:indexPath.section];
    NSString *phone = [tempDictionary objectForKey:@"phone"];
    //Remove From Wait List
    NSString *post = [NSString stringWithFormat:@"restaurant_name=%@&customer_phone_number=%@", self.restaurantUsername, phone];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shivs-macbook-pro.local/buzzr/data/restaurant_remove_guest.php"]]]; //URL Here
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    // Setting a timeout
    [request setTimeoutInterval: 20.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    NSLog(@"%@", post);
    
    if(conn) {
        NSLog(@"Connection Successful – Consumer Restaurant Front");
        
    } else {
        NSLog(@"Connection could not be made");
    }
    
    //Reload Table Data
    [self getRestaurantData];
}

-(void)seatCustomer:(NSIndexPath *)indexPath {
    //Seat Customer
}

-(void)addToWaitlist:(id)sender {
    //Animate Add Button
    POPSpringAnimation *spin = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    
    spin.fromValue = @(M_PI / 4);
    spin.toValue = @(0);
    spin.springBounciness = 20;
    spin.velocity = @(10);
    [addButton.layer pop_addAnimation:spin forKey:@"likeAnimation"];
    
    //Add to Wait List
    [self performSelector:@selector(showAddView) withObject:nil afterDelay:0.3];
}

-(void)showAddView {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(self.view.frame.size.height - ((addView.frame.size.height)/2));
    anim.springBounciness = 10;
    anim.springSpeed = 1.2;
    anim.dynamicsFriction = 14.0;
    [addView pop_addAnimation:anim forKey:@"slide"];
    
    addPhone.text = [NSString stringWithFormat:@""];
    addName.text = [NSString stringWithFormat:@""];

}

-(IBAction)doneAdding:(id)sender {
    if (addPhone.text.length > 0) {
        //Add to Wait List
        NSInteger row = [addSeats selectedRowInComponent:0];
        NSString *selectedSeats = [seatsPickerArray objectAtIndex:row];
        NSString *post = [NSString stringWithFormat:@"restaurant_name=%@&customer_phone_number=%@&customer_name=%@&seats=%@", self.restaurantUsername, addPhone.text, addName.text, selectedSeats];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shivs-macbook-pro.local/buzzr/data/restaurant_add_guest.php"]]]; //URL Here
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        
        // Setting a timeout
        [request setTimeoutInterval: 20.0];
        
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        NSLog(@"%@", post);
        
        if(conn) {
            NSLog(@"Connection Successful – Consumer Restaurant Front");
            
        } else {
            NSLog(@"Connection could not be made");
        }
        
        //Remove View
        [self cancelAdding:nil];
        [self getRestaurantData];
    }
    else {
        UIAlertView *invalidPhoneAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Please enter a valid US phone number (10 Digits)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidPhoneAlert show];

    }
    
}

-(IBAction)cancelAdding:(id)sender {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(self.view.frame.size.height+addView.frame.size.height);
    anim.springBounciness = 10;
    anim.springSpeed = 1.2;
    anim.dynamicsFriction = 14.0;
    [addView pop_addAnimation:anim forKey:@"slide"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Selected row
    selectedRow = indexPath;
    [tableView deselectRowAtIndexPath:selectedRow animated:YES];
    [self showDetails:selectedRow];
}

-(void)getRestaurantData {
    //     Check for Internet Connection
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.apple.com"]] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"%@", connect);
    if (connect == NULL) {
        //No Internet Connection
        [self showNoInternetMessage];
    }
    
    else if (self.restaurantUsername == NULL) {
        NSLog(@"Not Logged In!");
        [self logOut:nil];
    }
    
    else {
        NSString *post = [NSString stringWithFormat:@"restaurant_name=%@", self.restaurantUsername];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shivs-macbook-pro.local/buzzr/data/restaurant_consumer_inqueue.php"]]]; //URL Here
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        
        // Setting a timeout
        [request setTimeoutInterval: 20.0];
        
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        NSLog(@"%@", post);
        
        if(conn) {
            NSLog(@"Connection Successful – Consumer Restaurant Front");
            
        } else {
            NSLog(@"Connection could not be made");
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
        
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
        
        if ([jsonData count] > 0) {
            self.restaurantInfo = [[jsonData objectAtIndex:0] mutableCopy];
            NSString *restaurantTotalWaiting = [[restaurantInfo objectForKey:@"total_waiting"] stringValue];
            totalWaitingLabel.text = [NSString stringWithFormat:@"%@ Customers Waiting", restaurantTotalWaiting];
        }
        
        else {
            //No restaurant
            NSLog(@"No Restaurant");
        }
        
        if ([jsonData count] > 1) {
            self.queuedCustomers = [[jsonData objectAtIndex:1] mutableCopy];
        }
        
        else {
            //No Customers
            NSLog(@"No Customers");
        }
        
        
        NSLog(@"Queued Customers: %@", self.queuedCustomers);
        
        long queueCount = [self.queuedCustomers count];
        NSLog(@"Queue Count: %ld", queueCount);
        
        
        [self reloadTable];
    }
}

-(void)showNoInternetMessage {
    UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"You do not have an active internet connection. Please connect to the internet and try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [noInternetAlert show];
}

-(void)reloadTable {
    [tableView reloadData];
}

-(IBAction)logOut:(id)sender {
    [SSKeychain deletePasswordForService:@"restaurantLogin" account:self.restaurantUsername];
    self.restaurantUsername = @"";
    [self.queuedCustomers removeAllObjects];
    [self.restaurantInfo removeAllObjects];
    
    [self reloadTable];
    signInView.hidden = NO;
    
    [self performSegueWithIdentifier:@"rBackToInitial" sender:self];
    
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.seatsPickerArray count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.seatsPickerArray[row];
}



@end
