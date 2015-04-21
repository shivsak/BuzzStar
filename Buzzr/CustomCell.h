//
//  CustomCell.h
//  Buzzr
//
//  Created by Shiv Sakhuja on 2/6/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIButton *cellButton;
@property (weak, nonatomic) IBOutlet UILabel *cellRestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *cellQueue;
@property (weak, nonatomic) IBOutlet UILabel *cellRestaurantPhoneNumber;

@property (weak, nonatomic) NSString *cellRestaurantRealName;
@property (weak, nonatomic) NSString *cellRestaurantQueue;
@property (weak, nonatomic) NSString *cellRestaurantAddress;
@property (weak, nonatomic) NSString *cellRestaurantPhone;
@property (weak, nonatomic) NSString *cellRestaurantUsername;
@property (weak, nonatomic) NSString *cellRestaurantImagePath1;
@property (weak, nonatomic) NSString *cellRestaurantImagePath2;

@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIView *cellColorBarRight;
@property (weak, nonatomic) IBOutlet UIView *cellColorBarLeft;

@end
