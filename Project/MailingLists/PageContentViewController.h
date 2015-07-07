//
//  PageContentViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۳/۱۵ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
