//
//  ListContactsViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۸ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

#import "ListContactsViewController.h"
#import "AddRemoveContactsViewController.h"
#import "SelectGroupsViewController.h"
#import "eSoftContact.h"
#import "PasteGroupViewController.h"

@interface ListContactsViewController () {
    NSMutableArray *_contacts;
    NSMutableArray *_emails;
}
//- (void) setCurrentML:(ML *)currentML;
@end

@implementation ListContactsViewController

@synthesize currentML = _currentML;

#pragma mark - ActionSheet Delegate methodes


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)   // add photo ID
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
    else if (actionSheet.tag == 2)  // compose mail
    {
        if (buttonIndex == actionSheet.cancelButtonIndex)
            return;
        
        NSArray *recepients;
        MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
        compose.mailComposeDelegate = self;
        recepients = [[_currentMailingList objectForKey:ksEmailAddresses] componentsSeparatedByString:@", "];

        switch (buttonIndex) {
            case 0:
                [compose setToRecipients:recepients];
                break;
                
            case 1:
                [compose setCcRecipients:recepients];
                break;
                
            case 2:
                [compose setBccRecipients:recepients];
                break;
        }
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *signature = @"<br/><br/><br/><br/>_________________________<br/>Created with <a href=\"http://www.designbymax.com/app\" rel=\"external\" >Mailing Lists</a>";
            [compose setMessageBody:signature isHTML:YES];
            [self presentViewController:compose animated:YES completion:NULL];
        }
    }
}

#pragma mark - Compose email methodes

-(IBAction)composeEmail:(id)sender
{
    [self dismissPopUp:sender];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Compose New Email" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"TO:", @"CC:", @"BCC:", nil];
    actionSheet.tag = 2;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (IBAction)PasteGroup:(id)sender {
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Image Picker methodes

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
    
//    [self.navigationController.view addSubview:popOverView];
    [kAppDelegate.window addSubview:popOverView];

    [UIView animateWithDuration:.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         popOverView.frame = endFrame;
                     }
                     completion:^(BOOL finished){
                            popOverView.image = [UIImage imageNamed:@"AssignPopOverWindow.png"];
                         CGPoint center = self.navigationController.toolbar.center;
                         CGPoint centerInPopupView = [kAppDelegate.window convertPoint:center
                                                                                toView:popOverView];

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
    {
        [self freeVersionAlert:@"ChooseThumbnail"];
    }
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
    {
        [self freeVersionAlert:@"ChooseThumbnail"];
    }
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
    eSoftContact *contact = [[eSoftContact alloc] initWithRecord:(__bridge ABRecordRef)([_currentMailingList valueForKey:ksABRecordRef])];
    contact.pictureID = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImageView *groupPhotoIDImageView = (UIImageView *)[self.navigationController.view viewWithTag:501];
    groupPhotoIDImageView.image = [info valueForKey:@"UIImagePickerControllerEditedImage"];
}

//- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;
//{
//    NSLog(@"operation: %d", operation);
////    if (operation == UINavigationControllerOperationPop)
////        _isViewPulled = YES;
//    
//    return nil;
//}

#pragma mark - View methodes

- (void)initCache
{
    _thumbnailCache = [[NSCache alloc] init];
    _thumbnailCache.name = @"Contacts Thumbnails Cache";
    _thumbnailCache.countLimit = 15;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initCache];
    
    self.navigationController.delegate = self;
    
    _isViewPulled = NO;
    
    self.navigationController.navigationBar.translucent = NO;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Cancel";
    self.navigationItem.backBarButtonItem = backButton;

    
    self.title = ([[_currentMailingList valueForKey:ksFirstName] length] > 0 ?
                  [_currentMailingList valueForKey:ksFirstName] :
                  [_currentMailingList valueForKey:ksLastName]);
    
    CGRect rect = [[[UIApplication sharedApplication] keyWindow] rootViewController].view.bounds;
    
    if (_fadingView == nil)
        _fadingView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width/2-100, rect.size.height/2-40, 200.0, 80.0)];

    if (_fadingLabel == nil)
        _fadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 160, 30)];
    
    if (_fadingActivityIndicator == nil)
        _fadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(95, 50, 10, 10)];
    
    _fadingActivityIndicator.hidesWhenStopped = NO;
    
    _fadingView.layer.cornerRadius = 8.0;
    _fadingView.backgroundColor = [UIColor blackColor];
    _fadingView.userInteractionEnabled = NO;
    _fadingView.alpha = 0.0;
    _fadingLabel.text = @"";
    _fadingLabel.textAlignment = NSTextAlignmentCenter;
    _fadingLabel.textColor = [UIColor whiteColor];
    _fadingLabel.userInteractionEnabled = NO;
    _fadingLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0];
    _fadingLabel.text = @"Loading Contacts";
    [_fadingView addSubview:_fadingLabel];
    [_fadingView addSubview:_fadingActivityIndicator];
    [self.navigationController.view addSubview:_fadingView];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setToolbarHidden:NO animated:NO];

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
    center.x += (_isViewPulled ? 0 : 200);
    groupPictureIDButton.center = center;
    groupPhotoID.center = center;

    groupPhotoID.tag = 501;
    groupPictureIDButton.tag = 502;
    
    [self.navigationController.view addSubview:groupPhotoID];
    [self.navigationController.view addSubview:groupPictureIDButton];
    
    if (!_isViewPulled)
    {
        center.x -= 200;
        [UIView animateWithDuration:0.9 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             groupPhotoID.center = center;
                             groupPictureIDButton.center = center;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.delegate getBackCurrentMailingList:self didFinishEnteringItem:_currentML];
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadContacts];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void) showFadeInViewWithText:(NSString *)message
{

    _fadingActivityIndicator.hidden = NO;
    [_fadingActivityIndicator startAnimating];
    

    if (message)
    {
        _fadingLabel.text = message;
        _fadingActivityIndicator.hidden = YES;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.01];
    [self.fadingView setAlpha:0.75];
    [UIView commitAnimations];
}

- (void) showFadeOutView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [_fadingView setAlpha:0.0];
    [UIView commitAnimations];
    [_fadingActivityIndicator stopAnimating];
    
}


#pragma mark - AlertView methodes


- (void) showMergeAlertViewFor:(int)forAlert
{
    UIAlertView *alert;
    
    switch (forAlert) {
        case ksGroupContacts:
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Merge contacts" message:@"Do you want to merge contacts from selected group, with contacts in current Mailing List?\nIf you select 'Replace' all existing contacts in current MailingList will be replaced by the group's contacts." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Merge", @"Replace", nil];
            alert.tag = ksGroupContacts;

        }
            break;
            
        case ksPasteContacts:
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Merge contacts" message:@"Do you want to merge contacts entered manually with contacts in current Mailing List?\nIf you select 'Replace' all existing contacts in current MailingList will be replaced by the contacts you have typed in manually." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Merge", @"Replace", nil];
            alert.tag = ksPasteContacts;

        }
            break;
            
    }
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 6) && (buttonIndex != alertView.cancelButtonIndex)) // buy button clicked in premium version alert
    {
        [self dismissPopUp:self];
        NSArray *viewControllers = self.navigationController.viewControllers;
        NSLog(@"views: %@", viewControllers);
        MailingListViewController *rootViewController = (MailingListViewController*)[viewControllers objectAtIndex:0];
        [rootViewController performSegueWithIdentifier:@"Settings" sender:self];
        return;
    }
    
        
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

    switch (buttonIndex) {
        case 1:     // Merge
            if (alertView.tag == ksGroupContacts)
                [self addContactsFromGroup:_groupDictionary];
            else if (alertView.tag == ksPasteContacts)
                [self addPastedContacts:_pastedContatcs];
            [self loadContacts];
            [self.tableView reloadData];
            break;
            
        case 2:     // Replace
            
            for (int i = 0; i < _contacts.count; i++)
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];

            [_contacts removeAllObjects];
            [_emails removeAllObjects];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            if (alertView.tag == ksGroupContacts)
                [self addContactsFromGroup:_groupDictionary];
            else if (alertView.tag == ksPasteContacts)
                [self addPastedContacts:_pastedContatcs];
            [self loadContacts];
            [self.tableView reloadData];
            break;
    }
}


#pragma mark - Contact and Group managing


- (int) inCurrentMailingList:(ABRecordRef)RecordRef withEmail:(NSString *)emailAddress
{
    int counter = 0;
    if (RecordRef)  //contact in addressbook
    {
        ABRecordID contactRecordID = ABRecordGetRecordID(RecordRef);
        for (int i = 0; i < _contacts.count; i++)
        {
            if ((ABRecordGetRecordID((__bridge ABRecordRef)_contacts[i]) == contactRecordID) && ([_emails[i] isEqualToString:emailAddress]))
                counter++;
        }
    }
    else            // external contact
    {
        NSString *email;
        for (int i = 0; i < _emails.count; i++)
        {
            if ([_contacts[i] isKindOfClass:[NSString class]])
                email = [[_emails[i] componentsSeparatedByString:@"_$$$_"] objectAtIndex:1];
            else
                email = _emails[i];
                
            if ([emailAddress isEqualToString:email])
                counter++;
        }
    }
    return counter;
}

- (void)saveGroupEmails
{
    NSString *e;
    NSString *emailField = [[NSString alloc] init];
    NSString *fullName;
    NSString *emailAddress;
    NSCharacterSet *quot = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    
    for (int i = 0; i < _contacts.count; i++)
    {
        if ([_contacts[i] isKindOfClass:[NSString class]])
        {
            fullName = [[[_emails[i] componentsSeparatedByString:@"_$$$_"] objectAtIndex:0] stringByTrimmingCharactersInSet:quot];
            emailAddress = [[_emails[i] componentsSeparatedByString:@"_$$$_"] objectAtIndex:1];
        }
        else
        {
            ABContact* contact = [ABContact contactWithRecord:(ABRecordRef)_contacts[i]];
            fullName = [self fullName:contact.record];
            emailAddress = _emails[i];
        }
        e = [NSString stringWithFormat:@"\"%@\"<%@>, ", fullName, emailAddress];
        emailField = [emailField stringByAppendingString:e];
    }
    if (emailField.length)
        emailField = [emailField substringToIndex:emailField.length-2];
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    
    [dic setValue:emailField forKey:@"MailingList"];
    
    [_currentMailingList setValue:emailField forKey:ksEmailAddresses];
    eSoftContact *esc = [[eSoftContact alloc] initWithRecord:(__bridge ABRecordRef)[_currentMailingList valueForKey:ksABRecordRef]];
    
    esc.emails = dic;
}


-(ABRecordRef) findMailingListWithName:(NSString *)listName
{
    return nil;
}

- (void)loadContacts
{
    
    if (!_contacts)
        _contacts = [[NSMutableArray alloc] init];
    else
        [_contacts removeAllObjects];
    
    if (!_emails)
        _emails = [[NSMutableArray alloc] init];
    else
        [_emails removeAllObjects];
    
    NSArray* emailAddresses;
    NSString *emailField = [[_currentMailingList valueForKey:ksEmailAddresses] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (emailField.length)
        emailAddresses = [[NSArray alloc] initWithArray:[emailField componentsSeparatedByString:@">, \""]];
    
    if (emailAddresses.count)
        [self performSelectorInBackground:@selector(showFadeInViewWithText:) withObject:nil];
    else
        return;

    NSMutableArray *contactsNames = [NSMutableArray array];
    NSMutableArray *contactsEmails = [NSMutableArray array];
    for (__strong NSString* e in emailAddresses)
    {
        if (![[e substringToIndex:1] isEqualToString:@"\""])
        {
            e = [@"\"" stringByAppendingString:e];
        }
        if (![[e substringFromIndex:[e length]-1] isEqualToString:@">"])
        {
            e = [e stringByAppendingString:@">"];
        }
        NSArray *tmp = [e componentsSeparatedByString:@"\""];
        NSString *name = [tmp objectAtIndex:1];
        tmp = [e componentsSeparatedByString:@"<"];
        NSString *address = [[tmp objectAtIndex:1] substringToIndex:[[tmp objectAtIndex:1] length]-1];
        
        [contactsNames addObject:name];
        [contactsEmails addObject:address];
    }
    
    [self findContactsMatchingFullNameAndFillArrays:contactsNames andEmails:contactsEmails];
    
    [self sortContactsWith:([ABContactsHelper firstNameSorting] ? kMLSortUsingFirstName : kMLSortUsingLastName)];

    [self performSelectorInBackground:@selector(showFadeOutView) withObject:nil];
}

- (void) sortContactsWith:(sortDescriptor)descriptor
{
    NSMutableArray *sortName = [NSMutableArray array];
    [sortName removeAllObjects];
    
    for (int i = 0; i < _contacts.count; i++)
    {
        if ([_contacts[i] isKindOfClass:[NSString class]])
        {
            [sortName addObject:[[_emails[i] componentsSeparatedByString:@"_$$$_"] objectAtIndex:0]];
        } else {
            ABContact *contact = [ABContact contactWithRecord:(ABRecordRef)_contacts[i]];
            [sortName addObject:(descriptor == kMLSortUsingFirstName ? contact.firstname : contact.lastname)];
        }
    }
    
    NSMutableArray *combined = [NSMutableArray array];
    
    
    for (NSUInteger i = 0; i < _contacts.count; i++) {
        [combined addObject: @{@"sortName" : sortName[i], ksABRecordRef: _contacts[i], @"email": _emails[i]}];
    }
    
    NSSortDescriptor *contactSorter = [[NSSortDescriptor alloc] initWithKey:@"sortName"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];

    [combined sortUsingDescriptors:@[contactSorter]];
    
    [_contacts removeAllObjects];
    [_emails removeAllObjects];
    [sortName removeAllObjects];
    _contacts = [[combined valueForKey:ksABRecordRef] mutableCopy];
    _emails   = [[combined valueForKey:@"email"] mutableCopy];
//    sortName  = [[combined valueForKey:@"sortName"] mutableCopy];
}
- (void) findContactsMatchingFullNameAndFillArrays:(NSArray *)contactsFullNames andEmails:(NSArray *)contactsEmails
{
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *allRecords = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(ab));
    NSCharacterSet *space = [NSCharacterSet whitespaceCharacterSet];
    NSMutableArray *contactsMutableArray = [NSMutableArray array];
    NSDictionary *contact;
    
    NSUInteger numberOfContacts = allRecords.count;
    for (int i = 0; i < numberOfContacts; i++)
    {
        ABRecordRef record = (__bridge ABRecordRef)(allRecords[i]);
        NSString *fname = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lname = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        NSString *mname = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonMiddleNameProperty));
        NSString *organization = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonOrganizationProperty));
        
        if ((fname || lname || mname || organization) && (![organization isEqualToString:mailingListIdentifier]))
        {
            if (!fname) fname = @"";
            if (!lname) lname = @"";
            if (!mname) mname = @"";
            if (!organization) organization = @"";
            NSString *fullName = [[[[fname stringByAppendingFormat:@" %@", mname] stringByTrimmingCharactersInSet:space] stringByAppendingFormat:@" %@", lname] stringByTrimmingCharactersInSet:space];
            
            
            contact = [[NSDictionary alloc] initWithObjectsAndKeys:
                       (__bridge id)record, ksABRecordRef,
                       fullName, ksFullName,
                       organization, ksOrganization,
                       nil];
            [contactsMutableArray addObject:contact];
        }
    }
    
    
    //    contactsArray = contactsMutableArray;
    
    for (int i = 0; i < contactsFullNames.count; i++)
    {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K LIKE[CD] %@ OR %K LIKE[CD] %@",
                                  ksFullName, contactsFullNames[i], ksOrganization, contactsFullNames[i]];
        
        
        NSArray *filteredArray = [contactsMutableArray filteredArrayUsingPredicate:predicate];
        
        if (filteredArray.count == 0)
        {
            [_contacts addObject:ksExternalContact];
            [_emails addObject:[contactsFullNames[i] stringByAppendingFormat:@"_$$$_%@", contactsEmails[i]]];
        }
        else
        {
            [_contacts addObject:[filteredArray[0] objectForKey:ksABRecordRef]];
            [_emails addObject:contactsEmails[i]];
        }
        
    }
    if (ab) CFRelease(ab);
}

- (ABRecordRef) findContactsMatchingFullName:(NSString *)contactsFullName inArray:(NSArray *)contactsArray
{
    if (contactsArray == nil)   // no array defined, search through all contacts
    {
        ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
        NSArray *allRecords = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(ab));
        NSCharacterSet *space = [NSCharacterSet whitespaceCharacterSet];
        NSMutableArray *contactsMutableArray = [NSMutableArray array];
        NSDictionary *contact;
        
        NSUInteger numberOfContacts = allRecords.count;
        for (int i = 0; i < numberOfContacts; i++)
        {
            ABRecordRef record = (__bridge ABRecordRef)(allRecords[i]);
            NSString *fname = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
            NSString *lname = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
            NSString *mname = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonMiddleNameProperty));
            NSString *organization = ( NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonOrganizationProperty));
            
            if ((fname || lname || mname || organization) && (![organization isEqualToString:mailingListIdentifier]))
            {
                if (!fname) fname = @"";
                if (!lname) lname = @"";
                if (!mname) mname = @"";
                if (!organization) organization = @"";
                NSString *fullName = [[[[fname stringByAppendingFormat:@" %@", mname] stringByTrimmingCharactersInSet:space] stringByAppendingFormat:@" %@", lname] stringByTrimmingCharactersInSet:space];
                
                
                contact = [[NSDictionary alloc] initWithObjectsAndKeys:
                           (__bridge id)record, ksABRecordRef,
                           fullName, ksFullName,
                           organization, ksOrganization,
                           nil];
                [contactsMutableArray addObject:contact];
            }
        }
        
        if (ab) CFRelease(ab);
        
        contactsArray = contactsMutableArray;
    }
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K LIKE[CD] %@ OR %K LIKE[CD] %@",
                              ksFullName, contactsFullName, ksOrganization, contactsFullName];
    
    
    NSArray *filteredArray = [contactsArray filteredArrayUsingPredicate:predicate];

    if (filteredArray.count == 1)
        return (__bridge ABRecordRef)([filteredArray[0] objectForKey:ksABRecordRef]);
    else if (filteredArray.count == 0)
        NSLog(@"*************\nNo contacts found, External Contact\n**************\nfilteredArray: %@", filteredArray);
    else
        NSLog(@"*************\nMore than one contacts found\n**************\nfilteredArray: %@", filteredArray);

/*
    NSArray *nameParts = [[NSArray alloc] initWithArray:[contactsFullName componentsSeparatedByString:@" "]];
    NSArray *allContacts = [ABContactsHelper contactsMatchingName:[nameParts objectAtIndex:0]];
    //    NSPredicate *pred;
    for (ABContact *rec in allContacts)
    {
        NSString *name = [rec.firstname stringByAppendingFormat:@" %@", rec.lastname];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (name.length == 0)
            name = rec.organization;
        
        if ([name isEqualToString:contactsFullName])
            return rec;
    }
*/
    return nil;
}

- (NSString *) fullName:(ABRecordRef)record
{
    NSCharacterSet *space = [NSCharacterSet whitespaceCharacterSet];

    NSString *fname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    NSString *lname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
    NSString *mname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonMiddleNameProperty));
    NSString *organization = CFBridgingRelease(ABRecordCopyValue(record, kABPersonOrganizationProperty));
    if (!fname) fname = @"";
    if (!lname) lname = @"";
    if (!mname) mname = @"";
    if (!organization) organization = @"";
    NSString *fullName = [[[[fname stringByAppendingFormat:@" %@", mname] stringByTrimmingCharactersInSet:space] stringByAppendingFormat:@" %@", lname] stringByTrimmingCharactersInSet:space];
    
    if (fullName.length == 0)
        fullName = organization;
    
    return fullName;

}


- (void) addContactsFromGroup:(NSDictionary *)group
{
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    NSMutableArray *groupMembers = CFBridgingRelease(ABGroupCopyArrayOfAllMembers((__bridge ABRecordRef) [group valueForKey:ksABRecordRef]));
    NSMutableArray *contacts = [NSMutableArray array];
    NSMutableArray *emails = [NSMutableArray array];
    groupMembers = [groupMembers mutableCopy];
    for (int i = 0; i < groupMembers.count; i++)    //check if member has email acccount
    {
        ABMultiValueRef multiEmails = ABRecordCopyValue((__bridge ABRecordRef) groupMembers[i], kABPersonEmailProperty);
        if (!ABMultiValueGetCount(multiEmails))
        {
            [groupMembers removeObjectAtIndex:i];
            i--;
        }
        else
        {
            for (int j = 0; j < ABMultiValueGetCount(multiEmails); j++)
            {
                [contacts addObject:(id)groupMembers[i]];
                [emails addObject:(NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiEmails, j))];
            }
        }
        CFRelease(multiEmails);
    }
    for (int i = 0; i < contacts.count; i++)
    {
        if (![self inCurrentMailingList:(ABRecordRef)contacts[i] withEmail:emails[i]])
        {
            [_contacts addObject:contacts[i]];
            [_emails addObject:emails[i]];
        }
    }
    
    [self saveGroupEmails];

    if (ab) CFRelease(ab);

}

-(void) addPastedContacts:(NSArray *)pastedContacts
{
    for (int i = 0; i < pastedContacts.count; i++)
    {
        if (![self inCurrentMailingList:nil withEmail:[pastedContacts[i] objectForKey:ksEmailAddresses]])
        {
            [_contacts addObject:ksExternalContact];
            [_emails addObject:[[pastedContacts[i] objectForKey:ksFullName] stringByAppendingFormat:@"_$$$_%@", [pastedContacts[i] objectForKey:ksEmailAddresses]]];    
        }
    }
    
    [self saveGroupEmails];

}

#pragma mark - Delegate methodes

-(void)getBackPullView:(BOOL)pullled
{
    _isViewPulled = YES;
}

- (void) getBackContacts:(NSArray *)c andEmails:(NSArray *)e
{
    _contacts = [NSMutableArray arrayWithArray:c];
    _emails   = [NSMutableArray arrayWithArray:e];
    
    _fadingLabel.text = @"Updating Contacts";
    
    [self saveGroupEmails];
//    [self sortContactsWith:([ABContactsHelper firstNameSorting] ? kMLSortUsingFirstName : kMLSortUsingLastName)];
//    [self.tableView reloadData];
}

- (void) getBackGroup:(NSDictionary*) group
{
    _groupDictionary = group;
    
    _fadingLabel.text = @"Updating Contacts";

    if (_contacts.count)
        [self showMergeAlertViewFor:ksGroupContacts];
//        [self performSelectorInBackground:@selector(showMergeAlertView) withObject:nil];
    else
        [self addContactsFromGroup:group];
}

-(void) getBackPastedContacts:(NSArray *)contacts
{
    if (!contacts.count)
        return;
    
    _pastedContatcs = contacts;

    _fadingLabel.text = @"Updating Contacts";
    
    if (_contacts.count)
        [self showMergeAlertViewFor:ksPasteContacts];
    else
        [self addPastedContacts:contacts];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_contacts.count == 0)
        _composeButton.enabled = NO;
    else
        _composeButton.enabled = YES;
    
    return _contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UIImageView *MLImageView = (UIImageView *)[cell viewWithTag:200];
    UILabel *contactName = (UILabel *)[cell viewWithTag:201];
    contactName.highlightedTextColor = [UIColor whiteColor];
    
    UILabel *contactEmail = (UILabel *)[cell viewWithTag:202];
    
    if ([_contacts[indexPath.row] isKindOfClass:[NSString class]])
    {
        MLImageView.image = [UIImage imageNamed:@"noPictureID"];
        contactName.text = [[_emails[indexPath.row] componentsSeparatedByString:@"_$$$_"] objectAtIndex:0];
        contactEmail.text = [[_emails[indexPath.row] componentsSeparatedByString:@"_$$$_"] objectAtIndex:1];
    }
    else
    {
        ABContact *contact = [ABContact contactWithRecord:(ABRecordRef)_contacts[indexPath.row]];

        UIImage *image = [_thumbnailCache objectForKey:[NSNumber numberWithInt:contact.recordID]];
        if (image) {
            MLImageView.image = image;
        }
        else
        {
            MLImageView.image = [UIImage imageNamed:@"noPictureID.png"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // get the UIImage
                
                UIImage *image = contact.thumbnail;
                if (!image) {
                    image = [UIImage imageNamed:@"noPictureID.png"];
                }
                
                // if we found it, then update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // if the cell is visible, then set the image
                    
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        UIImageView* MLImageView = (UIImageView*)[cell viewWithTag:200];
                        MLImageView.image = image;
                    }
                    
                });
                
                [_thumbnailCache setObject:image forKey:[NSNumber numberWithInt:contact.recordID]];
            });
        }
        contactName.text = [self fullName:contact.record];
        contactEmail.text = _emails[indexPath.row];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *name = (UILabel *)[cell viewWithTag:201];
    UILabel *email = (UILabel *)[cell viewWithTag:202];
    
    NSLog(@"contact name font: %@\nemail font: %@", [[name font] fontName], [[email font] fontDescriptor]);
    
    
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [_contacts removeObjectAtIndex:indexPath.row];
        [_emails removeObjectAtIndex:indexPath.row];
        if (!_deleteFX)
            _deleteFX = [[SoundEffect alloc] initWithSoundNamed:@"DeleteItem.wav"];
        [_deleteFX play];

        [self saveGroupEmails];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self dismissPopUp:sender];
    if ([segue.identifier isEqualToString:@"AddRemoveContactsSegue"])
    {
        AddRemoveContactsViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.contacts = _contacts;
        vc.emails = _emails;
        vc.currentML = _currentML;
    }
    else if ([segue.identifier isEqualToString:@"selectGroupsSegue"])
    {
        SelectGroupsViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"PasteContactSegue"])
    {
        PasteGroupViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }

}

-(void)dealloc
{
    _delegate = nil;
    _currentML = nil;
    _currentMailingList = nil;
    _groupDictionary = nil;    
}
@end
