//
//  SelectGroupsViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۱/۹ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListContactsViewController.h"

@protocol ModalViewDelegate;

@interface SelectGroupsViewController : UITableViewController
{
    id<ModalViewDelegate> delegate;

}
@property (nonatomic, strong) id<ModalViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *groupsDictionary;

@end
