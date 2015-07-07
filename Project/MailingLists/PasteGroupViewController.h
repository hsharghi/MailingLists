//
//  PasteGroupViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۲/۲۲ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "MailingListViewController.h"
#import "ListContactsViewController.h"
#import <QuartzCore/QuartzCore.h>

@protocol ModalViewDelegate;

@interface PasteGroupViewController : UIViewController <UIAlertViewDelegate>
{
    id<ModalViewDelegate> delegate;

}

@property (nonatomic, strong) id<ModalViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *listOfEmails;
@property (weak, nonatomic) IBOutlet UIButton *pasteButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


- (IBAction)pasteFromClipboard:(id)sender;
- (IBAction)clearContents:(id)sender;
- (IBAction)saveList:(id)sender;
- (IBAction)tapTokhmi:(id)sender;

@end

