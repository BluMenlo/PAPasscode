//
//  PAPasscodeContainerViewController.h
//  PAPasscode Example
//
//  Created by Justin Buchanan 2 on 2/27/14.
//  Copyright (c) 2014 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPasscodeViewController.h"

@interface PAPasscodeContainerViewController : UIViewController

- (instancetype)initWithPasscodeVC:(PAPasscodeViewController *)passcodeVC backgroundView:(UIView *)bg;

@property (nonatomic, strong)	PAPasscodeViewController	*passcodeVC;
@property (nonatomic, strong)	UINavigationController		*passcodeNavVC;
@property (nonatomic, strong)	UIImage						*blurredImage;

@end
