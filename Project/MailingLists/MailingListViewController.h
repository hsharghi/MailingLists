//
//  MasterViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۶ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ABContactsHelper.h"
#import "ABContact.h"
#import "eSoftContact.h"
#import "AppDelegate.h"
#import "ListContactsViewController.h"
#import "SoundEffect.h"
#import "SettingsViewController.h"



#define mailingListIdentifier @"__MailingList"

typedef uint32_t MLIdentifierField;
enum {
    kMLIdentifierUnknown        = 0,
    kMLIdentifierInFirstName    = 1,
    kMLIdentifierInLastName     = 2,
    kMLIdentifierInOrganization = 3
};



@interface MailingListViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, SecondViewControllerDelegate> {
    BOOL _thumbnailTapped;
    UIBarButtonItem *settingButton;
    
}

- (void)showQuickTour:(id)sender;
- (IBAction) pickThumbnailImage:(id)sender;
- (void) Purchased;


@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageImages_3_5;
@property (strong, nonatomic) NSArray *pageIndicatorImages;

@property (nonatomic, weak)   IBOutlet UIBarButtonItem *editOptionsLabel;
@property (nonatomic, strong) NSCache* thumbnailCache;
@property (nonatomic, strong) NSCache* emailCountCache;
@property (nonatomic, strong)   NSIndexPath* currentIndexPath;
@property (nonatomic, readwrite) BOOL deleting;
@property (nonatomic, weak)   ABContact *returnedMailingList;
@property (nonatomic, strong) SoundEffect* deleteFX;

@end
