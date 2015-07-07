//
//  ListContactsViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۸ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ABContact.h"
#import "ABContactsHelper.h"
#import "SoundEffect.h"


#define ksGroupContacts 1001
#define ksPasteContacts 1002
#define ksExternalContact @"ExContact"
#define ksFirstName     @"FirstName"
#define ksLastName      @"LastName"
#define ksMiddleName    @"MiddleName"
#define ksOrganization  @"Organization"
#define ksFullName      @"FullName"
#define ksGroupName     @"GroupName"
#define ksABRecordRef   @"ABRecordRef"
#define ksABRecordID    @"ABRecordID"
#define ksEmailAddresses @"EmailAddresses"
#define ksEmailsArray   @"EmailsArray"
#define ksLabelsArray   @"LabelsArray"
#define ksMembersCount  @"MemberCount"
#define ksEmailsCount   @"EmailsCount"


typedef uint32_t sortDescriptor;
enum {
    kMLSortUsingFirstName       = 0,
    kMLSortUsingLastName        = 1,
};

@protocol SecondViewControllerDelegate <NSObject>
- (void)getBackCurrentMailingList:(id)controller didFinishEnteringItem:(ABContact *)currentMailingList;
@end


@protocol ModalViewDelegate
@optional
- (void) getBackGroup:(NSDictionary *) group;
- (void) getBackContacts:(NSArray *)c andEmails:(NSArray *)e;
- (void) getBackPastedContacts:(NSArray *)contacts;
- (void) getBackPullView:(BOOL)pullled;
@end

@interface ListContactsViewController : UITableViewController <ModalViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    ABContact *currentML;
    BOOL _isViewPulled;
}

- (IBAction) pickImage:(id)sender;
- (IBAction) composeEmail:(id)sender;
- (IBAction) PasteGroup:(id)sender;
- (IBAction) dismissPopUp:(id)sender;

@property (nonatomic, weak)     IBOutlet UIBarButtonItem *composeButton;
@property (nonatomic, strong)   NSCache*                thumbnailCache;
@property (nonatomic, strong)   ABContact*              currentML;
@property (nonatomic, strong)   NSMutableDictionary*    currentMailingList;
@property (nonatomic, strong)   NSArray*                pastedContatcs;
@property (nonatomic, strong)   NSDictionary*           groupDictionary;
@property (nonatomic, readwrite) ABRecordID             currentRecordID;
@property (nonatomic, strong)   UIView*                 fadingView;
@property (nonatomic, strong)   UILabel*                fadingLabel;
@property (nonatomic, strong)   UIActivityIndicatorView* fadingActivityIndicator;
@property (nonatomic, weak)     id <SecondViewControllerDelegate> delegate;
@property (nonatomic, strong)   SoundEffect* deleteFX;

@end
