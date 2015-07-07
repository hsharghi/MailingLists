//
//  DetailViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۶ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ML.h"

typedef uint32_t sortDescriptor;
enum {
    kMLSortUsingFirstName       = 0,
    kMLSortUsingLastName        = 1,
};


@interface MailingListContactsViewController : UIViewController

@property (strong, nonatomic) ML* currentML;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
