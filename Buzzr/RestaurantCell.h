//
//  RestaurantCell.h
//  Buzzr
//
//  Created by Shiv Sakhuja on 2/7/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIButton *cellButton;
@property (weak, nonatomic) IBOutlet UILabel *cellCustomerName;
@property (weak, nonatomic) IBOutlet UILabel *cellCustomerTableFor;
@property (weak, nonatomic) IBOutlet UILabel *cellCustomerPhoneNumber;

@property (weak, nonatomic) NSString *customerImageName;
@property (weak, nonatomic) NSString *customerEmail;
@property (weak, nonatomic) NSString *customerPhone;
@property (weak, nonatomic) NSString *customerName;

@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIView *cellColorBarRight;
@property (weak, nonatomic) IBOutlet UIView *cellColorBarLeft;

@end
