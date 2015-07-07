//
//  AddRemoveContactsViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۲/۳۰ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "AddRemoveContactsViewController.h"
#import "MailingListViewController.h"
#import "eSoftContact.h"
#import "AppDelegate.h"

@interface UIImage (Extra)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

@implementation UIImage (Extra)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@interface AddRemoveContactsViewController ()
{
    NSMutableArray *contactsArray;
    NSMutableArray *searchResult;
    NSCache *_thumbnailCache;
    BOOL _removeSubCell;
    BOOL _subCellIsVisible;
}
@end

@implementation AddRemoveContactsViewController

@synthesize delegate = _delegate;

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedIndex = -1;
    switchIsTapped = NO;
    
    self.title = @"Add/Remove";
    
    [self createContactsDictionaryWithRecords:[ABContactsHelper contactsWithEmail]];
    [self sortContactsWith:-1];
    [self initThumbnailsCache];
    
    if (_fadingView == nil)
        _fadingView = [[UIView alloc] initWithFrame:CGRectMake(60, 80, 180, 50)];
    
    if (_fadingLabel == nil)
        _fadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 160, 30)];
    _fadingView.layer.cornerRadius = 8.0;
    _fadingView.backgroundColor = [UIColor blackColor];
    _fadingView.userInteractionEnabled = NO;
    _fadingView.alpha = 0.0;
    _fadingLabel.text = @"";
    _fadingLabel.textAlignment = NSTextAlignmentCenter;
    _fadingLabel.textColor = [UIColor whiteColor];
    _fadingLabel.userInteractionEnabled = NO;
    _fadingLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0];
    [_fadingView addSubview:_fadingLabel];
    [self.navigationController.view addSubview:_fadingView];
    
    _subCellIsVisible = NO;
    _removeSubCell = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_delegate getBackPullView:YES];
    for (UIView *v in self.navigationController.view.subviews)
    {
        if ((v.tag == 501) || (v.tag == 502))
            [v removeFromSuperview];
    }
    
    if ([self isMovingFromParentViewController])
    {
        if (self.navigationController.delegate == self)
        {
            self.navigationController.delegate = nil;
        }
    }
    
    [_fadingLabel removeFromSuperview];
    [_fadingView removeFromSuperview];
    _fadingLabel = nil;
    _fadingView = nil;
    [_fadingTimer invalidate];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    UIImageView *groupPhotoID = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 53, 53)];
    groupPhotoID.image = _currentML.thumbnail;
    if (!groupPhotoID.image)
        groupPhotoID.image = [UIImage imageNamed:@"noPictureID_Group"];
    
    UIButton *groupPictureIDButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"CenterButton_Normal.png"];
    UIImage *buttonHighlightedImage = [UIImage imageNamed:@"CenterButton_Highlighted.png"];
    [groupPictureIDButton addTarget:self action:@selector(pickImage:) forControlEvents:UIControlEventTouchUpInside];
    groupPictureIDButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [groupPictureIDButton setImage:buttonImage forState:UIControlStateNormal];
    [groupPictureIDButton setImage:buttonHighlightedImage forState:UIControlStateHighlighted];
    CGPoint center = self.navigationController.toolbar.center;
    center.y -= 10;
    groupPictureIDButton.center = center;
    groupPhotoID.center = center;
    
    groupPhotoID.tag = 501;
    groupPictureIDButton.tag = 502;
    
    [self.navigationController.view addSubview:groupPhotoID];
    [self.navigationController.view addSubview:groupPictureIDButton];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (numberOfContactsWithNoName > 0)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        if (([[ud stringForKey:@"ShowNoNameContactsAlert"] isEqualToString:@"YES"]) ||
            ([ud stringForKey:@"ShowNoNameContactsAlert"] == nil))
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts with no name" message:[NSString stringWithFormat:@"You have %ld contact(s) with no name in you Address book. Contacts without name or organization can not be added to any list.\nOpen 'Contacts' app, and try to add a name to unnamed contacts.", (long)numberOfContactsWithNoName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Don't show", nil];
            [alert show];
        }
    }
}

#pragma mark - SelectionCell Delegate Methods

-(void)expandedSwitchTapped:(SelectionCell *)cell indexOfSwitch:(NSUInteger)index
{
    NSMutableArray *currentContactsArray;
    UITableView *currentTableView;
    
    if (self.searchDisplayController.isActive)
    {
        currentContactsArray = searchResult;
        currentTableView = self.searchDisplayController.searchResultsTableView;
    }
    else
    {
        currentContactsArray = contactsArray;
        currentTableView = self.tableView;
    }
    
    NSArray *emailsArray = [currentContactsArray[cell.tag] objectForKey:ksEmailsArray];
    [self toggleSelectEmail:emailsArray[index] forContact:currentContactsArray[cell.tag] on:[cell isSwitchOnForIndex:index]];
}

-(void)SwitchTapped:(SelectionCell *)cell
{
    NSMutableArray *currentContactsArray;
    UITableView *currentTableView;
    
    if (self.searchDisplayController.isActive)
    {
        currentContactsArray = searchResult;
        currentTableView = self.searchDisplayController.searchResultsTableView;
    }
    else
    {
        currentContactsArray = contactsArray;
        currentTableView = self.tableView;
    }
    
    NSArray *emailsArray = [currentContactsArray[cell.tag] objectForKey:ksEmailsArray];
    if (emailsArray.count > 1)
    {
        switchIsTapped = YES;
        MLSelectedEmailState state = (cell.isSwitchOn ? kMLSelectedEmailNone : kMLSelectedEmailAll);
        cell.switchState = state;
        for (int i = 0; i < emailsArray.count; i++)
        {
            [self toggleSelectEmail:emailsArray[i] forContact:currentContactsArray[cell.tag] on:state];
            [cell setSwitchState:state forSwitchIndex:i];
        }
    }
    
    [self tableView:currentTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:cell.tag inSection:0]];
    
}

#pragma mark - VFX & SFX

- (void) showFadeInView
{
    if (self.fadingTimer)
        [self.fadingTimer invalidate];
    
    _fadingLabel.text = [NSString stringWithFormat:@"%lu %@ selected", (unsigned long)_emails.count, (_emails.count > 1 ? @"emails" : @"email")];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.fadingView setAlpha:0.75];
    
    self.fadingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                        target:self
                                                      selector:@selector(showFadeOutView)
                                                      userInfo:nil repeats:NO];
    [UIView commitAnimations];
    
}

- (void) showFadeOutView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [_fadingView setAlpha:0.0];
    [UIView commitAnimations];
}

#pragma mark - AlertView Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 6) && (buttonIndex != alertView.cancelButtonIndex))   // free version alert
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = @"Back";
        self.navigationItem.backBarButtonItem = backButton;
        
        [self dismissPopUp:self];
        NSArray *viewControllers = self.navigationController.viewControllers;
        NSLog(@"views: %@", viewControllers);
        MailingListViewController *rootViewController = (MailingListViewController*)[viewControllers objectAtIndex:0];
        [rootViewController performSegueWithIdentifier:@"Settings" sender:self];
        return;
        
    }
    //  "Don't Show Again" button pressed
    if(buttonIndex == 1)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"NO" forKey:@"ShowNoNameContactsAlert"];
    }
/*  
    else if (buttonIndex == 2)  // "Show unnamed Contacts
    {
        UnnamedContactsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UnnamedContactsViewController"];
        vc.unnamedContacts = arrayOfContactsWithNoName;
        self.navigationItem.backBarButtonItem.title = @"Back";
        
        [self.navigationController pushViewController:vc animated:YES];
    }
 */
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:     // choose photo from library
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
            
        case 1:        // take photo
        {
            if (buttonIndex == actionSheet.cancelButtonIndex)
                return;
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.allowsEditing = YES;
            imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Initialize and Search Contacts

- (void)initThumbnailsCache
{
    _thumbnailCache = [[NSCache alloc] init];
    _thumbnailCache.name = @"Contacts Thumbnails Cache";
    _thumbnailCache.countLimit = 20;
}

-(void)createContactsDictionaryWithRecords:(NSArray*)recordsArray
{
    if (!contactsArray)
        contactsArray = [[NSMutableArray alloc] init];
    else
        [contactsArray removeAllObjects];
    
    numberOfContactsWithNoName = 0;
    arrayOfContactsWithNoName = [NSMutableArray new];
    
    NSCharacterSet *space = [NSCharacterSet whitespaceCharacterSet];
    
    for (id person in recordsArray)
    {
        NSString *fname = (NSString *) CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonFirstNameProperty));
        NSString *lname = (NSString *) CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonLastNameProperty));
        NSString *mname = (NSString *) CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonMiddleNameProperty));
        NSString *organization = (NSString *) CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonOrganizationProperty));
        
        CFTypeRef emails = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonEmailProperty);
        
        fname = (fname ? fname : @"");
        lname = (lname ? lname : @"");
        mname = (mname ? mname : @"");
        organization = (organization ? organization : @"");
        
        if (([fname isEqualToString:@""]) && ([lname isEqualToString:@""]) && ([organization isEqualToString:@""]))
        {
            numberOfContactsWithNoName++;
            [arrayOfContactsWithNoName addObject:(id)person];
        }
        else if (![organization isEqualToString:mailingListIdentifier] &&   // check if contact is not a mailing list, then add it
                 ![fname isEqualToString:mailingListIdentifier] &&
                 ![lname isEqualToString:mailingListIdentifier])
        {
            NSString *fullName = [[[[fname stringByAppendingFormat:@" %@", mname] stringByTrimmingCharactersInSet:space] stringByAppendingFormat:@" %@", lname] stringByTrimmingCharactersInSet:space];
            
            NSArray *emailsArray = (NSArray *)CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emails));
            NSMutableArray *labelsArray = [NSMutableArray array];
            for (int i = 0; i < ABMultiValueGetCount(emails); i++)
            {
                CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(emails, i);
                NSString *emailLabel =(NSString*) CFBridgingRelease(ABAddressBookCopyLocalizedLabel(labelRef));
                if (emailLabel.length == 0) emailLabel = @"Email";
                [labelsArray addObject:emailLabel];
                if (labelRef) CFRelease(labelRef);
            }
            
            NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:(id)person, ksABRecordRef,
                                     fname, ksFirstName,
                                     lname, ksLastName,
                                     mname, ksMiddleName,
                                     fullName, ksFullName,
                                     organization, ksOrganization,
                                     emailsArray, ksEmailsArray,
                                     (NSArray*)labelsArray , ksLabelsArray,
                                     [NSNumber numberWithInteger:emailsArray.count], ksEmailsCount,
                                     nil];
            
            
            [contactsArray addObject:contact];
        }
        
        if (emails)
            CFRelease(emails);
    }
}

- (void) sortContactsWith:(sortDescriptor)descriptor
{
    //    NSString *key = (descriptor == kMLSortUsingFirstName ? @"FirstName" : @"LastName");
    NSString *key = ksFullName;
    
    NSSortDescriptor *contactSorter = [[NSSortDescriptor alloc] initWithKey:key
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)];
    
    [contactsArray sortUsingDescriptors:@[contactSorter]];
}

-(void)searchContacts
{
    if (!searchResult)
        searchResult = [[NSMutableArray alloc] init];
    else
        [searchResult removeAllObjects];
    
    NSMutableArray *subPredicates = [NSMutableArray array];
    
    NSArray *searchComponents = [_searchBar.text componentsSeparatedByString:@" "];
    for (int i=0; i<searchComponents.count; i++) {
        if ([searchComponents[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
        {
            NSPredicate *pFirstName = [NSPredicate predicateWithFormat:@"%K beginswith[CD] %@ or %K contains[CD] %@", ksFirstName, searchComponents[i], ksFirstName, [NSString stringWithFormat:@" %@", searchComponents[i]]];
            NSPredicate *pMiddleName = [NSPredicate predicateWithFormat:@"%K beginswith[CD] %@ or %K contains[CD] %@", ksMiddleName, searchComponents[i], ksMiddleName, [NSString stringWithFormat:@" %@", searchComponents[i]]];
            NSPredicate *pLastName = [NSPredicate predicateWithFormat:@"%K beginswith[CD] %@ or %K contains[CD] %@", ksLastName, searchComponents[i], ksLastName, [NSString stringWithFormat:@" %@", searchComponents[i]]];
            NSPredicate *pOrganization = [NSPredicate predicateWithFormat:@"%K beginswith[CD] %@ or %K contains[CD] %@", ksOrganization, searchComponents[i], ksOrganization, [NSString stringWithFormat:@" %@", searchComponents[i]]];
            
            [subPredicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:@[pFirstName, pLastName, pMiddleName, pOrganization]]];
        }
    }
    
    NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    searchResult = [[contactsArray filteredArrayUsingPredicate:filter] mutableCopy];
    
    [self.tableView reloadData];
    
}

-(BOOL)removeSubCellFrom:(NSMutableArray *)arrayOfContacts andTableView:(UITableView *)tableView
{
    if (_subCellIsVisible)   // subCell is Visible, Now hide it
    {
        if (kAppDelegate.playSoundFX) {
            _closeFX = [[SoundEffect alloc] initWithSoundNamed:@"Close01.wav"];
            [_closeFX play];
        }
        
        NSUInteger subCellIndex = [arrayOfContacts indexOfObject:[NSNull null]];
        NSIndexPath *subCellIndexPath = [NSIndexPath indexPathForRow:subCellIndex inSection:0];
        
        [arrayOfContacts removeObject:[NSNull null]];
        [tableView deleteRowsAtIndexPaths:@[subCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        _subCellIsVisible = NO;
        return YES;
    }
    return NO;
}

-(NSIndexPath *)addSubCellTo:(NSMutableArray *)arrayOfContacts andTableView:(UITableView *)tableView forContactAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_subCellIsVisible)   // subCell is NOT Visible, Now add it
    {
        if (kAppDelegate.playSoundFX) {
            [_closeFX stop];
            _openFX = [[SoundEffect alloc] initWithSoundNamed:@"Open01.wav"];
            [_openFX play];
        }
        NSIndexPath *subCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        [arrayOfContacts insertObject:[NSNull null] atIndex:subCellIndexPath.row];
        [tableView insertRowsAtIndexPaths:@[subCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        _subCellIsVisible = YES;
        
        return subCellIndexPath;
    }
    return nil;
}

#pragma mark - SearchDisplayController & SearchBar Methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchContacts];
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.tableView reloadData];
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    UIButton *btnCancel;
    
    //    if (!btnCancel) {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIView *topView = self.searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                btnCancel = (UIButton *)subView;
            }
        }
    } else {
        for (UIView *subView in self.searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UIButton")]) {
                btnCancel = (UIButton *)subView;
            }
        }
    }
    if (btnCancel)
        [btnCancel setTitle:@"Done" forState:UIControlStateNormal];
    //    }
    //    else
    //        [btnCancel setTitle:@"Done" forState:UIControlStateNormal];
    
    
}

#pragma mark - Get & Set contacts properties


- (UIImage *)getContactThumbnail:(ABRecordRef)recordRef
{
    UIImage *img = nil;
    
    // can't get image from a ABRecordRef copy
    ABRecordID contactID = ABRecordGetRecordID(recordRef);
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABRecordRef originalContactRef = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
    
    if (ABPersonHasImageData(originalContactRef)) {
        NSData *imgData = (NSData*)CFBridgingRelease(ABPersonCopyImageDataWithFormat(originalContactRef, kABPersonImageFormatThumbnail));
        img = [UIImage imageWithData: imgData];
    }
    if (addressBook)
        CFRelease(addressBook);
    
    return img;
}

- (int) inCurrentMailingList:(NSDictionary *)contact
{
    int counter = 0;
    ABRecordID contactRecordID = ABRecordGetRecordID((__bridge ABRecordRef)([contact valueForKey:ksABRecordRef]));
    
    
    for (id c in _contacts)
    {
        if (ABRecordGetRecordID((__bridge ABRecordRef)c) == contactRecordID)
            counter++;
    }
    
    return counter;
}

- (MLSelectedEmailState) getSelectedEmailStateForContact:(NSDictionary*)contact
{
    MLSelectedEmailState result = kMLSelectedEmailNone;
    ABRecordID contactRecordID = ABRecordGetRecordID((__bridge ABRecordRef)([contact valueForKey:ksABRecordRef]));
    
    for (NSDictionary *person in contactsArray)
    {
        ABRecordID personRecordID = ABRecordGetRecordID((__bridge ABRecordRef)([person valueForKey:ksABRecordRef]));
        if (personRecordID == contactRecordID)
        {
            NSInteger emailsCount = [[person valueForKey:ksEmailsArray] count];
            NSInteger selectedEmailsCount = [self inCurrentMailingList:contact];
            
            if ((selectedEmailsCount > 0) && (selectedEmailsCount == emailsCount))
                result = kMLSelectedEmailAll;
            else if ((selectedEmailsCount > 0) && (selectedEmailsCount < emailsCount))
                result = kMLSelectedEmailSome;
            else if (selectedEmailsCount == 0)
                result = kMLSelectedEmailNone;
        }
    }
    return result;
}

- (MLSelectedEmailState) getSelectedEmailStateForEmail:(NSString *)emailAddress
{
    MLSelectedEmailState result = kMLSelectedEmailNone;
    
    for (NSString* email in _emails)
    {
        if ([emailAddress isEqualToString:email])
            result = kMLSelectedEmailAll;
    }
    return result;
}


- (void) toggleSelectEmail:(NSString *)emailAddress forContact:(NSDictionary *)contact on:(BOOL)toggle
{
    if (kAppDelegate.playSoundFX) {
        if (!_selectionSwitchFX)
            _selectionSwitchFX = [[SoundEffect alloc] initWithSoundNamed:@"SwitchChange.wav"];
        [_selectionSwitchFX play];
    }
    
    NSUInteger index = [_emails indexOfObject:emailAddress];
    
    if (toggle) // turn on email
    {
        if (index == NSNotFound)
        {
            [_emails addObject:emailAddress];
            [_contacts addObject:(id)[contact valueForKey:ksABRecordRef]];
        }
    }
    else                // turn off email
    {
        if (index != NSNotFound)
        {
            [_emails removeObjectAtIndex:index];
            [_contacts removeObjectAtIndex:index];
        }
    }
    
    [self showFadeInView];
    
}

#pragma mark - Image Picker methods
-(IBAction)pickImage:(id)sender
{
    if ([self.navigationController.view viewWithTag:901])
    {
        [self dismissPopUp:sender];
        return;
    }
    
    UIButton *backgroundTap = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backgroundTap addTarget:self action:@selector(dismissPopUp:) forControlEvents:UIControlEventTouchUpInside];
    backgroundTap.tag = 901;
    [self.navigationController.view addSubview:backgroundTap];
    
    UIImageView *popOverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
    popOverView.image = [UIImage imageNamed:@"PopOverWindowBG.png"];
    popOverView.userInteractionEnabled = YES;
    popOverView.tag = 902;
    CGPoint center = self.navigationController.toolbar.center;
    
    CGRect startFrame, endFrame;
    CGPoint startCenterPoint;
    startCenterPoint = CGPointMake(160, center.y - 22);
    startFrame = CGRectMake(0,0, 25, 10);
    endFrame = CGRectMake(32.5, center.y - 168, 255, 130);
    
    popOverView.frame = startFrame;
    popOverView.center = startCenterPoint;
    
    [kAppDelegate.window addSubview:popOverView];
    
    [UIView animateWithDuration:.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         popOverView.frame = endFrame;
                     }
                     completion:^(BOOL finished){
                         popOverView.image = [UIImage imageNamed:@"AssignPopOverWindow.png"];
                         CGPoint center = self.navigationController.toolbar.center;
                         CGPoint centerInPopupView = [kAppDelegate.window convertPoint:center toView:popOverView];
                         
                         UIButton *takePhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 205, 30)];
                         centerInPopupView.y -= 119.5;
                         takePhoto.center =  centerInPopupView;
                         if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                         {
                             [takePhoto setImage:[UIImage imageNamed:@"PopOver_TakePhoto.png"] forState:UIControlStateNormal];
                             [takePhoto addTarget:self action:@selector(takePictureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                         }
                         else
                         {
                             [takePhoto setImage:[UIImage imageNamed:@"PopOver_CameraNotAvailable.png"] forState:UIControlStateNormal];
                         }
                         [popOverView addSubview:takePhoto];
                         
                         UIButton *chooseExisting = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 205, 30)];
                         [chooseExisting setImage:[UIImage imageNamed:@"PopOver_ChooseExisting.png"] forState:UIControlStateNormal];
                         [chooseExisting addTarget:self action:@selector(chooseExistingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                         [popOverView addSubview:chooseExisting];
                         centerInPopupView.y += 35;
                         chooseExisting.center = centerInPopupView;
                         
                     }];
    
}

- (void)freeVersionAlert:(NSString *)source
{
    if ([source isEqualToString:@"ChooseThumbnail"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limited Version" message:@"This feature is not availbale in free version. Please purchase Premium version." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        alert.tag = 6;
        alert.delegate = self;
        [alert show];
        
    }
    
}

-(void)takePictureButtonTapped:(id)sender
{
    if (kAppDelegate.premiumVersion)
    {
        [self dismissPopUp:sender];
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
    else
        [self freeVersionAlert:@"ChooseThumbnail"];
}

-(void)chooseExistingButtonTapped:(id)sender
{
    if (kAppDelegate.premiumVersion)
    {
        [self dismissPopUp:sender];
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
    else
        [self freeVersionAlert:@"ChooseThumbnail"];
}


-(IBAction)dismissPopUp:(id)sender
{
    UIButton *backgroundTap = (UIButton *)[kAppDelegate.window viewWithTag:901];
    UIImageView *popOverView = (UIImageView *)[kAppDelegate.window viewWithTag:902];
    for (UIView *button in popOverView.subviews)
        [button removeFromSuperview];
    
    CGPoint center = self.navigationController.toolbar.center;
    CGPoint startCenterPoint = CGPointMake(160, center.y - 22);
    
    CGRect startFrame = CGRectMake(startCenterPoint.x - 25.0/2 ,startCenterPoint.y - 10.0/2, 25, 10);
    
    [UIView animateWithDuration:.2 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:0.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         popOverView.frame = startFrame;
                     }
                     completion:^(BOOL finished){
                         [backgroundTap removeFromSuperview];
                         [popOverView removeFromSuperview];
                         
                     }];
    
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    eSoftContact *contact = [[eSoftContact alloc] initWithRecord:_currentML.record];
    contact.pictureID = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImageView *groupPhotoIDImageView = (UIImageView *)[self.navigationController.view viewWithTag:501];
    groupPhotoIDImageView.image = [info valueForKey:@"UIImagePickerControllerEditedImage"];
}


- (IBAction) save:(id)sender
{
    [_delegate getBackContacts:_contacts andEmails:_emails];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *currentContactsArray;
    if (tableView == self.tableView)
        currentContactsArray = contactsArray;
    else
        currentContactsArray = searchResult;
    
    if ((selectedIndex == indexPath.row) && ([[currentContactsArray[indexPath.row] objectForKey:ksEmailsArray] count] > 1))
    {
        CGFloat height = 2 * 70.0 + (([[currentContactsArray[indexPath.row] objectForKey:ksEmailsArray] count] - 1) * 50.0);
        return height;
    }
    else
        return 70.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return contactsArray.count;
    else
        return searchResult.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectionCell";
    
    NSArray *currentContactsArray;
    if (tableView == self.tableView)
        currentContactsArray = contactsArray;
    else
        currentContactsArray = searchResult;
    
    NSInteger indexOfCurrentContact = indexPath.row;
    NSDictionary *currentContact = currentContactsArray[indexOfCurrentContact];
    
    SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.tag = indexOfCurrentContact;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.contactName.text = [currentContact objectForKey:ksFullName];
    
    // Contact Email
    if ([[currentContact objectForKey:ksEmailsCount] integerValue] == 1)
        cell.emailAddress.text = [[currentContact objectForKey:ksEmailsArray] objectAtIndex:0];
    else
        cell.emailAddress.text = [NSString stringWithFormat:@"%ld email addresses", (long)[[currentContact objectForKey:ksEmailsCount] integerValue]];
    
    // Contact Thumbnail
    UIImage *image = [_thumbnailCache objectForKey:[currentContact valueForKey:ksABRecordID]];
    if (image) {
        cell.contactPictureID.image = image;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // get the UIImage
            UIImage *image = [self getContactThumbnail:(__bridge ABRecordRef)([currentContact valueForKey:ksABRecordRef])];
            if (!image) {
                image = [UIImage imageNamed:@"noPictureID"];
            }
            
            // if we found it, then update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // if the cell is visible, then set the image
                SelectionCell *cell;
                cell = (SelectionCell*) [tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    cell.contactPictureID.image = image;
                }
            });
            
            [_thumbnailCache setObject:image forKey:[currentContact valueForKey:ksABRecordID]];
        });
    }
    
    // Contact selected-email checkbox image
    [cell setSwitchState:[self getSelectedEmailStateForContact:currentContact]];
    
    if ((selectedIndex == indexOfCurrentContact) &&
        ([[currentContactsArray[indexOfCurrentContact] objectForKey:ksEmailsArray] count] > 1))
    {
        cell = [cell expandedCellWithArrayOfEmails:[currentContactsArray[indexOfCurrentContact] objectForKey:ksEmailsArray] andLabels:[currentContactsArray[indexOfCurrentContact] objectForKey:ksLabelsArray]];
        
        for (int i = 0; i < [[currentContactsArray[indexOfCurrentContact] objectForKey:ksEmailsArray] count]; i++)
        {
            MLSelectedEmailState state = [self getSelectedEmailStateForEmail:[[currentContactsArray[indexOfCurrentContact] objectForKey:ksEmailsArray] objectAtIndex:i]];
            [cell setSwitchState:state forSwitchIndex:i];
        }
        
    }
    
    cell.delegate = self;
    
    /*
     //////////////      Create subCell
     if (currentContactsArray[indexPath.row] == [NSNull null])
     {
     long indexOfContact = indexPath.row - 1;
     MultiEmailCell *cell = [tableView dequeueReusableCellWithIdentifier:SubCellIdentifier];
     if (cell == nil) {
     cell = [[MultiEmailCell alloc] initWithArrayOfEmails:[currentContactsArray[indexOfContact] objectForKey:ksEmailsArray] andLabels:[currentContactsArray[indexOfContact] objectForKey:ksLabelsArray] withStyle:UITableViewCellStyleDefault reuseIdentifier:SubCellIdentifier];
     }
     else
     cell = [cell cellWithArrayOfEmails:[currentContactsArray[indexOfContact] objectForKey:ksEmailsArray] andLabels:[currentContactsArray[indexOfContact] objectForKey:ksLabelsArray]];
     
     for (int i = 0; i < [[currentContactsArray[indexOfContact] objectForKey:ksEmailsArray] count]; i++)
     {
     MLSelectedEmailState state = [self getSelectedEmailStateForEmail:[[currentContactsArray[indexOfContact] objectForKey:ksEmailsArray] objectAtIndex:i]];
     [cell setSwitchState:state forIndex:i];
     }
     
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     cell.tag = indexOfSubCell * 1000;
     cell.delegate = self;
     
     //        cell.tagLabel.text = [NSString stringWithFormat:@"%2d", cell.tag];
     
     return cell;
     
     }
     
     ////////////        Create contactCell
     
     SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     
     
     if (cell == nil) {
     cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
     
     cell.delegate = self;
     cell.tag = indexOfCurrentContact;
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     //    cell.tagLabel.text = [NSString stringWithFormat:@"%2d", cell.tag];
     
     // Configure the cell...
     // Contact Name
     cell.contactName.text = [currentContact objectForKey:ksFullName];
     
     // Contact Email
     if ([[currentContact objectForKey:ksEmailsCount] integerValue] == 1)
     cell.emailAddress.text = [[currentContact objectForKey:ksEmailsArray] objectAtIndex:0];
     else
     cell.emailAddress.text = [NSString stringWithFormat:@"%ld email addresses", [[currentContact objectForKey:ksEmailsCount] integerValue]];
     
     // Contact Thumbnail
     UIImage *image = [_thumbnailCache objectForKey:[currentContact valueForKey:ksABRecordID]];
     if (image) {
     cell.contactPictureID.image = image;
     }
     else
     {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     
     // get the UIImage
     UIImage *image = [self getContactThumbnail:(__bridge ABRecordRef)([currentContact valueForKey:ksABRecordRef])];
     if (!image) {
     image = [UIImage imageNamed:@"noPictureID"];
     }
     
     // if we found it, then update UI
     dispatch_async(dispatch_get_main_queue(), ^{
     
     // if the cell is visible, then set the image
     SelectionCell *cell;
     cell = (SelectionCell*) [tableView cellForRowAtIndexPath:indexPath];
     if (cell) {
     cell.contactPictureID.image = image;
     }
     });
     
     [_thumbnailCache setObject:image forKey:[currentContact valueForKey:ksABRecordID]];
     });
     }
     
     // Contact selected-email checkbox image
     [cell setSwitchState:[self getSelectedEmailStateForContact:currentContact]];
     
     
     */
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // fix for separators bug in iOS 7
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    UITableView *currentTableView;
    NSMutableArray *currentContactsArray;
    
    if (tableView == self.tableView)
    {
        currentTableView = tableView;
        currentContactsArray = contactsArray;
    }
    else
    {
        currentTableView = self.searchDisplayController.searchResultsTableView;
        currentContactsArray = searchResult;
    }
    
    NSUInteger numberOfEmails = [[currentContactsArray[indexPath.row] objectForKey:ksEmailsArray] count];
    BOOL playSound = kAppDelegate.playSoundFX;
    
    //The user is selecting the cell which is currently expanded
    //we want to minimize it back
    if((selectedIndex == indexPath.row) && (numberOfEmails > 1) && (!switchIsTapped))
    {
        if (playSound) {
            if (!_closeFX)
                _closeFX = [[SoundEffect alloc] initWithSoundNamed:@"Close01.wav"];
            [_closeFX play];
        }
        
        selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        return;
    }
    
    //First we check if a cell is already expanded.
    //If it is we want to minimize make sure it is reloaded to minimize it back
    if ((selectedIndex >= 0) && (switchIsTapped))
        playSound = NO;
    
    if ((selectedIndex >= 0) && (!switchIsTapped))
    {
        NSIndexPath *previousPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        SelectionCell *previousCell = (SelectionCell *)[currentTableView cellForRowAtIndexPath:previousPath];
        SelectionCell *currentCell = (SelectionCell *)[currentTableView cellForRowAtIndexPath:indexPath];
        
        [tableView reloadRowsAtIndexPaths:@[previousPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ((previousCell.contentView.frame.size.height > 70) && (currentCell.contentView.frame.size.height <= 70) && (playSound))
        {
            if (!_closeFX)
                _closeFX = [[SoundEffect alloc] initWithSoundNamed:@"Close01.wav"];
            [_closeFX play];
        }
        else if ((previousCell.contentView.frame.size.height > 70) && (currentCell.contentView.frame.size.height > 70) && (playSound))
        {
            if (!_openFX)
                _openFX = [[SoundEffect alloc] initWithSoundNamed:@"Open01.wav"];
            [_openFX play];
            
        }
    }
    
    //Finally set the selected index to the new selection and reload it to expand
    
    if (numberOfEmails > 1)
        selectedIndex = indexPath.row;
    
    SelectionCell *cell;
    NSUInteger indexOfCurrentContact = indexPath.row;
    cell = (SelectionCell*)[currentTableView cellForRowAtIndexPath:indexPath];
    
    if (numberOfEmails == 1)
    {
        
        [cell setSwitchState:(cell.isSwitchOn ? kMLSelectedEmailNone : kMLSelectedEmailAll)];
        [self toggleSelectEmail:[[currentContactsArray[indexOfCurrentContact] objectForKey:ksEmailsArray] objectAtIndex:0]
                     forContact:currentContactsArray[indexOfCurrentContact]
                             on:cell.switchState];
    }
    else
    {
        if (playSound) {
            if (!_openFX)
                _openFX = [[SoundEffect alloc] initWithSoundNamed:@"Open01.wav"];
            [_openFX play];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    
    // check if cell is out of view and scroll it into view
    CGRect cellFrame = [currentTableView.superview convertRect:[currentTableView cellForRowAtIndexPath:indexPath].frame
                                                      fromView:currentTableView];
    CGRect tableViewFrame = currentTableView.superview.frame;
    tableViewFrame.origin.y += 64;  // navigation bar height
    tableViewFrame.size.height -= (64 + 44);   // navigation bar height + toolbar height
    
    if (!CGRectContainsRect(tableViewFrame, cellFrame))
    {
        UITableViewScrollPosition scrollPositioin;
        NSIndexPath *scrollCellIndexPath = nil;
        if (cellFrame.origin.y < tableViewFrame.origin.y)    // we have to scroll the parent cell to top
        {
            scrollPositioin = UITableViewScrollPositionTop;
            scrollCellIndexPath = indexPath;
        }
        else if (cellFrame.origin.y + cellFrame.size.height  > tableViewFrame.size.height)  // we have to scroll the sub cell to bottom
        {
            scrollPositioin = UITableViewScrollPositionBottom;
            scrollCellIndexPath = indexPath;
        }
        
        if (scrollCellIndexPath) {
            [currentTableView scrollToRowAtIndexPath:scrollCellIndexPath atScrollPosition:scrollPositioin animated:YES];
        }
        
    }
    
    switchIsTapped = NO;
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        NSLog(@"finished: ");
        
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
