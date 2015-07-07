//
//  AddRemoveContactsViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۲/۳۰ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"
#import "SelectionCell.h"
#import "SoundEffect.h"
#import "ListContactsViewController.h"
#import "UnnamedContactsViewController.h"

@protocol ModalViewDelegate;

@interface AddRemoveContactsViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, SelectionCellDelegate, UIScrollViewDelegate>
{
    id<ModalViewDelegate> delegate;
    int numberOfContactsWithNoName;
    NSMutableArray *arrayOfContactsWithNoName;
    NSInteger selectedIndex;
    BOOL switchIsTapped;
}

- (IBAction)save:(id)sender;
- (IBAction)dismissPopUp:(id)sender;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) id<ModalViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray* contacts;
@property (strong, nonatomic) NSMutableArray* emails;
@property (strong, nonatomic) UIView* fadingView;
@property (strong, nonatomic) UILabel* fadingLabel;
@property (strong, nonatomic) NSTimer* fadingTimer;
@property (strong, nonatomic) ABContact* currentML;
@property (strong, nonatomic) SoundEffect* openFX;
@property (strong, nonatomic) SoundEffect* closeFX;
@property (strong, nonatomic) SoundEffect* selectionSwitchFX;


@end
