//
//  MasterViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۶ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

#define YOUR_APP_STORE_ID 887175815

#import "MailingListViewController.h"
#import "PageContentViewController.h"
#import "AppDelegate.h"

//static uint32_t const kMLDefaultMLIdentifierField = kMLIdentifierInOrganization;


@interface MailingListViewController () {
    NSMutableArray *_MLArray;
//    NSMutableArray *_MLArray2;
    
    UIImageView *_addNewImageView;
    UIButton *_optionsButton;
}

-(MLIdentifierField) getMLIdentifierField:(ABContact *)mailingListContact;
@end

@implementation MailingListViewController

- (void)initCache
{
    _thumbnailCache = [[NSCache alloc] init];
    _thumbnailCache.name = @"Contacts Thumbnails Cache";
    _thumbnailCache.countLimit = 10;
    
    _emailCountCache = [[NSCache alloc] init];
    _emailCountCache.name = @"Number of Emails Cache";
    _emailCountCache.countLimit = 10;
}

- (void)getBackCurrentMailingList:(id)controller didFinishEnteringItem:(ABContact *)currentMailingList
{
    // this method is called when user has tapped Back button from ListContactsViewController
    [_thumbnailCache removeObjectForKey:[NSNumber numberWithInt:currentMailingList.recordID]];
}

- (MLIdentifierField) getMLIdentifierField:(ABContact *)mailingListContact
{
    if ([mailingListContact.firstname rangeOfString:mailingListIdentifier].location != NSNotFound)
        return kMLIdentifierInFirstName;
    else if ([mailingListContact.lastname rangeOfString:mailingListIdentifier].location != NSNotFound)
        return kMLIdentifierInLastName;
    else if ([mailingListContact.organization rangeOfString:mailingListIdentifier].location != NSNotFound)
        return kMLIdentifierInOrganization;
    
    return kMLIdentifierUnknown;
}

- (void) sortContactsWith:(sortDescriptor)descriptor
{
    NSMutableArray *sortName = [NSMutableArray array];
    [sortName removeAllObjects];

    for (ABContact* c in _MLArray)
    {
        [sortName addObject:(descriptor == kMLSortUsingFirstName ? c.firstname : c.lastname)];
    }
    
    NSMutableArray *combined = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < _MLArray.count; i++) {
        [combined addObject: @{@"sortName" : sortName[i], @"ABContact": _MLArray[i]}];
    }
    
    NSSortDescriptor *groupSorter = [[NSSortDescriptor alloc] initWithKey:@"sortName"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    [combined sortUsingDescriptors:@[groupSorter]];
    
    [_MLArray removeAllObjects];
    _MLArray = [[combined valueForKey:@"ABContact"] mutableCopy];
}

- (void) loadML
{
    if (!_MLArray)
        _MLArray = [[NSMutableArray alloc] init];
    else
        [_MLArray removeAllObjects];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6 or later
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted)
    {
        _MLArray = [NSMutableArray arrayWithArray:[ABContactsHelper contactsMatchingName:mailingListIdentifier]];
        //        _MLArray2 = [NSMutableArray arrayWithArray:[MyContact contactsMatchingName:mailingListIdentifier]];
        [self sortContactsWith:([ABContactsHelper firstNameSorting] ? kMLSortUsingFirstName : kMLSortUsingLastName)];
    }
    else
        NSLog(@"\n***** can't access contacts ******\n");
    
    //    if (_MLArray.count == 0)
    //        _editOptionsLabel.title = @"Tap + to create new group";
    
    
    [self.tableView reloadData];
}


- (void)appstoreRate:(id)object {
    // Show Alert View for app store rate
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate App" message:@"Did you like Mailing Lists App? Please take a moment and RATE US on The App Store. Thank You!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rate Us!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = 4;
    [alert show];
}

- (void)enteredForeground:(id)object {
    // Reload the tableview
    [self loadML];
}

- (void)hideOptionsButtonTimer:(NSTimer*)timer
{
    _optionsButton.hidden = YES;
    _optionsButton.alpha = 1.0;
}

- (void)optionsButtonTapped:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    _optionsButton.alpha = 0;
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hideOptionsButtonTimer:)
                                   userInfo:nil
                                    repeats:NO];
    
    kAppDelegate.showEditOptionsPopUp = NO;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:kShowEditOptionsPopUp];
    [ud synchronize];
}


- (void)editButtonTapped:(id)sender
{
    if (self.editing)
    {
        [super setEditing:NO animated:YES];
        //  show settings toolbar icon
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        if (settingButton)
        {
            [toolbarItems addObject:settingButton];
            [self setToolbarItems:toolbarItems];
        }

        self.navigationItem.rightBarButtonItem.enabled = YES;
        _editOptionsLabel.title = @"";
        _optionsButton.hidden = YES;
    }
    else
    {
        [super setEditing:YES animated:YES];
//          hide settings toolbar icon
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        for (UIView *item in toolbarItems)
        {
            if (item.tag == 999){
                settingButton = (UIBarButtonItem *)item;
                [toolbarItems removeObject:settingButton];
                [self setToolbarItems:toolbarItems];
            }
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
        _editOptionsLabel.title = @"Tap on a group for options";
        if (kAppDelegate.showEditOptionsPopUp)
            _optionsButton.hidden = NO;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [self loadML];
    
}

-(void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setToolbarHidden:YES animated:NO];

}


- (void)showQuickTour:(id)sender
{
    NSLog(@"show quick tour");
    if (!kAppDelegate.showQuickTour)
        return;

    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    for (UIView *item in toolbarItems)
    {
        if (item.tag == 999){
            settingButton = (UIBarButtonItem *)item;
            [toolbarItems removeObject:settingButton];
            [self setToolbarItems:toolbarItems];
        }
    }
    _pageTitles = @[@"Add a new Mailing List", @"Edit properties of a list", @"2 ways to add contacts to a list", @"1- From Add/Remove panel", @"2- Import or type in manually", @"You can use the list in ANY app!"];
    _pageImages = @[@"ScreenShots_01.png", @"ScreenShots_02.png", @"ScreenShots_03.png", @"ScreenShots_04.png", @"ScreenShots_05.png", @"ScreenShots_06.png"];
    _pageImages_3_5 = @[@"ScreenShots_01_3.5.png", @"ScreenShots_02_3.5.png", @"ScreenShots_03_3.5.png", @"ScreenShots_04_3.5.png", @"ScreenShots_05_3.5.png", @"ScreenShots_06_3.5.png"];
    

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    

    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height + 6);
    self.navigationController.view.backgroundColor = [UIColor colorWithRed:209/255.0 green:49/255.0 blue:46/255.0 alpha:1];
    _pageViewController.view.tag = 1009;
    _pageViewController.view.alpha = 1;
    _pageViewController.view.backgroundColor = [UIColor colorWithRed:209/255.0 green:49/255.0 blue:46/255.0 alpha:1];

    [self presentViewController:_pageViewController animated:YES completion:^{
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = CGRectMake(262, 38, 40, 40);
        [dismissButton setImage:[UIImage imageNamed:@"CloseButton"] forState:UIControlStateNormal];
        [dismissButton setImage:[UIImage imageNamed:@"CloseButton_Highlighted"] forState:UIControlStateHighlighted];
        [dismissButton addTarget:self action:@selector(hideQuickTour:) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.tag = 1008;
        dismissButton.alpha = 1;
        
//        [self.navigationController.view addSubview:dismissButton];
        [_pageViewController.view addSubview:dismissButton];
        
        kAppDelegate.showQuickTour = NO;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:NO forKey:kShowQuickTour];
        [ud synchronize];

    }];
    
//    [self.navigationController.view addSubview:_pageViewController.view];
    
    
//    [UIView animateWithDuration:0.7
//                     animations:^{
//                         _pageViewController.view.alpha = 1;
//                         dismissButton.alpha = 1;
//                     }
//                     completion:^(BOOL finished){
//                         self.tableView.hidden = YES;
//
//                     }];
}

-(void)hideQuickTour:(id)sender
{
//    UIButton *dismissButton = (UIButton *)sender;
//    BOOL toolbarHiddenState = [dismissButton.titleLabel.text boolValue];
//    [self.navigationController setToolbarHidden:toolbarHiddenState animated:YES];

    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if (settingButton)
    {
        [toolbarItems addObject:settingButton];
        [self setToolbarItems:toolbarItems];        
    }
    self.tableView.hidden = NO;
    
    for (UIView *view in self.pageViewController.view.subviews)
    {
        if (view.tag == 1008)
            [view removeFromSuperview];
    }
    [self.pageViewController dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enteredForeground:)
                                                 name:kEnteredForground
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appstoreRate:)
                                                 name:kAppStoreRate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showQuickTour:)
                                                 name:kShowQuickTour
                                               object:nil];
    

    
    
    
    
    
    [self initCache];
    
    
    
    if (!_addNewImageView)
        _addNewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 92)];
    _addNewImageView.hidden = YES;
    _addNewImageView.alpha = 0.0f;
    _addNewImageView.image = [UIImage imageNamed:@"StartingCellBG@2x.png"];
    _addNewImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:(UIView*)_addNewImageView];

    if (!_optionsButton)
        _optionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 75, 320, 75)];
    _optionsButton.hidden = YES;
    _optionsButton.alpha = 0.95f;
    _optionsButton.backgroundColor = [UIColor clearColor];
    [_optionsButton setBackgroundImage:[UIImage imageNamed:@"MailingListOptions@2x.png"] forState:UIControlStateNormal];
    [_optionsButton addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:(UIView*)_optionsButton];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Back";
    self.navigationItem.backBarButtonItem = backButton;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.editButtonItem.target = self;
    self.editButtonItem.action = @selector(editButtonTapped:);
    
    _editOptionsLabel.title = @"";
    _deleting = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewGroup:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
//    [_editOptionsLabel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                              [UIColor colorWithRed:245/255.0 green:245/255.0 blue:250/255.0 alpha:1.0], NSForegroundColorAttributeName, nil,
//                                              shadow, NSShadowAttributeName,
//                                               [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:32.0], NSFontAttributeName, nil] forState:UIControlStateNormal];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - List Operations

- (ABRecordID) addGroupWithName:(NSString *)groupName
{
    ABContact *newML = [ABContact contact];
    if ([ABContactsHelper firstNameSorting])
        newML.firstname = groupName;
    else
        newML.lastname  = groupName;
    
    newML.organization = mailingListIdentifier;
    newML.note = @"Created by Mailing Lists App\nAdd this contact as a recepient into TO:, Cc: or BCc field and send email will be sent to all memebers of this list.";
    NSError *error;
    BOOL result = [ABContactsHelper addContact:newML withError:&error];
    
    if (!result) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't create new list!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        NSLog(@"error adding contact: %@", error.localizedDescription);
    }
    
    return newML.recordID;
}

- (BOOL) removeGroup:(ABContact *)contact withError:(NSError **)error
{
    BOOL ret = NO;
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABRecordID recordID = contact.recordID;
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressbook, recordID);
    CFErrorRef CFError = NULL;
    ABAddressBookRemoveRecord(addressbook, recordRef, &CFError);
    if (ABAddressBookHasUnsavedChanges(addressbook))
        ret = ABAddressBookSave(addressbook, &CFError);
    
    if (CFError) CFBridgingRelease(CFError);
    if (addressbook) CFRelease(addressbook);
    
    
    return ret;
}

- (BOOL) renameGroup:(ABContact *)contact withNewName:(NSString *)newName
{
    BOOL ret = NO;
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABRecordID recordID = contact.recordID;
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressbook, recordID);
    CFErrorRef CFError = NULL;
    ABPropertyID property;
    CFStringRef name = ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    property = (name ? kABPersonFirstNameProperty : kABPersonLastNameProperty);
    
    if (name)
        CFRelease(name);
    
    ABRecordSetValue(recordRef, property, (__bridge CFTypeRef)(newName), &CFError);
    
    if (ABAddressBookHasUnsavedChanges(addressbook))
        ret = ABAddressBookSave(addressbook, &CFError);
    
    if (CFError) {
        CFBridgingRelease(CFError);
    }
    CFRelease(addressbook);
    
    return ret;
}

- (void)renameList
{
    ABContact *list = _MLArray[_currentIndexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename List"
                                                    message:[NSString stringWithFormat:@"Enter new name for list \"%@\"",list.mailingListName]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Rename", nil];
    alert.tag = 3;
    alert.delegate = self;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //    [[alert textFieldAtIndex:0] setText:list.mailingListName];
    //    [[alert textFieldAtIndex:0] setSelectedTextRange:[[alert textFieldAtIndex:0]
    //                                                      textRangeFromPosition:[alert textFieldAtIndex:0].beginningOfDocument
    //                                                     toPosition:[alert textFieldAtIndex:0].endOfDocument]];
    [alert show];
}

- (void)deleteConfirmation
{
    ABContact *list = _MLArray[_currentIndexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete List"
                                                    message:[NSString stringWithFormat:@"Are you sure to delete \"%@\" from your mailing lists?",list.mailingListName]
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 2;
    alert.delegate = self;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)freeVersionAlert:(NSString *)source
{
    if ([source isEqualToString:@"Options"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limited Version" message:@"This feature is not availbale in free version. Please purchase Premium version." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        alert.tag = 6;
        alert.delegate = self;
        [alert show];

    }
    else if ([source isEqualToString:@"NoOfGroupsExceed"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limited Version" message:@"In free version you can't have more than one Mailing List. Please purchase Premium version for unlimited Mailing Lists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        alert.tag = 5;
        alert.delegate = self;
        [alert show];
    }
    
}

- (void)addNewGroup:(id)sender
{
    if ((kAppDelegate.premiumVersion) || (_MLArray.count < 1))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New List" message:@"Enter a name for new mailing list group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        alert.tag = 1;
        alert.delegate = self;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else
    {
        [self freeVersionAlert:@"NoOfGroupsExceed"];
    }
}



- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
        case 1:         // Add New List
        {
            if (buttonIndex == alertView.cancelButtonIndex)
                return;
            
            if ([alertView textFieldAtIndex:0].text.length > 0)
            {
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
                dispatch_async(queue, ^{
                    // Perform async operation
                    // Call your method/function here
                    NSString *groupName = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [self addGroupWithName:groupName];

                    dispatch_sync(dispatch_get_main_queue(), ^{
                        // Update UI
                        // Example:
                        [alertView dismissWithClickedButtonIndex:0 animated:YES];
                        [self loadML];
                        for (int i = 0; i<_MLArray.count; i++)
                        {
                            if ([[(ABContact *)_MLArray[i] mailingListName] isEqualToString:groupName])
                            {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                                [self.tableView scrollToRowAtIndexPath:indexPath
                                                      atScrollPosition:UITableViewScrollPositionMiddle
                                                              animated:YES];
                            }
                        }
                    });
                });
                
            }
        }
            break;
            
        case 2:         // Delete List
        {
            if (buttonIndex == alertView.cancelButtonIndex)
                return;
            

            if ([self removeGroup:_MLArray[_currentIndexPath.row] withError:nil])
            {
                [_MLArray removeObjectAtIndex:_currentIndexPath.row];
                _deleting = YES;
            }
            
            [self.tableView deleteRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationRight];
            if (kAppDelegate.playSoundFX) {
                if (!_deleteFX)
                    _deleteFX = [[SoundEffect alloc] initWithSoundNamed:@"DeleteItem.wav"];
                [_deleteFX play];
            }
            if (_MLArray.count == 0)
            {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    self.tableView.editing = NO;
                    _addNewImageView.hidden = NO;

                });

            }
        }
            break;
            
        case 3:         // Rename List
        {
            if (buttonIndex == alertView.cancelButtonIndex)
                return;
            
            if ([alertView textFieldAtIndex:0].text.length > 0)
            {
                ABContact *list = _MLArray[_currentIndexPath.row];
                if (![[alertView textFieldAtIndex:0].text isEqualToString:list.mailingListName])
                {
                    if ([self renameGroup:list withNewName:[alertView textFieldAtIndex:0].text])
                        [self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    //                    NSLog(@"name after rename: %@", newcontact.contactName);
                }
            }
        }
            break;
            
        case 4:         // Rate in Appstore
        {
            kAppDelegate.showRateAlert = NO;
            if (alertView.cancelButtonIndex == buttonIndex)
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setInteger:3 forKey:kNumberOfLaunches];
            }
            else
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:kRated forKey:kAppStoreRate];
                [ud synchronize];

                static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
                static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";
                
                NSURL *rateAppURL = [NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, YOUR_APP_STORE_ID]];
                [[UIApplication sharedApplication] openURL:rateAppURL];
            }
        }
            break;

        case 5:     // buy premium version
        case 6:
            if (buttonIndex != alertView.cancelButtonIndex)
                [self performSegueWithIdentifier:@"Settings" sender:self];
            break;
            
        default:
            break;
    }
    
    [self loadML];
    
}

#pragma mark - Table View

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_MLArray.count == 0)
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        if (_addNewImageView.hidden)
        {
            _addNewImageView.alpha = 0;
            _addNewImageView.hidden = NO;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.5];
            [_addNewImageView setAlpha:1.0];
            [UIView commitAnimations];
        }
    }
    else if (_MLArray.count > 0)
    {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        _addNewImageView.hidden = YES;
    }
    return _MLArray.count;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TICK;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    _addNewImageView.alpha = 1.0f;

    UIButton *MLImageViewButton = (UIButton *)[cell viewWithTag:100];
//    [MLImageViewButton addTarget:self action:@selector(pickThumbnailImage:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *groupName = (UILabel *)[cell viewWithTag:101];
    UILabel *groupCount = (UILabel *)[cell viewWithTag:102];
    
    cell.backgroundColor = [UIColor colorWithRed:241/255.0 green:250/255.0 blue:254/255.0 alpha:1];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellBG_Indicator.png"]
                                           highlightedImage:[UIImage imageNamed:@"MailingListCellBG_Selection_Indicator.png"]];
    cell.editingAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellBG_Indicator.png"]
                                                  highlightedImage:[UIImage imageNamed:@"MailingListCellBG_Selection_Indicator.png"]];
    
    UIView *selectedBGView = [[UIView alloc] init];
    selectedBGView.backgroundColor = [UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1];
    cell.selectedBackgroundView = selectedBGView;
    
    ABContact *mailinglistContact = _MLArray[indexPath.row];
    cell.tag = mailinglistContact.recordID;
    
    UIImage *image = [_thumbnailCache objectForKey:[NSNumber numberWithInt:mailinglistContact.recordID]];
    if (image) {
        [MLImageViewButton setImage:image forState:UIControlStateNormal];
    }
    else
    {
        [MLImageViewButton setImage:[UIImage imageNamed:@"noPictureID_Group"] forState:UIControlStateNormal];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            // get the UIImage
            
            UIImage *image = mailinglistContact.thumbnail;
            if (!image) {
                image = [UIImage imageNamed:@"noPictureID_Group"];
            }
            
            // if we found it, then update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // if the cell is visible, then set the image
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    UIButton* MLImageViewButton = (UIButton*)[cell viewWithTag:100];
                    [MLImageViewButton setImage:image forState:UIControlStateNormal];
                }
                
            });
            [_thumbnailCache setObject:image forKey:[NSNumber numberWithInt:mailinglistContact.recordID]];
        });
    }
    
    groupCount.text = [_emailCountCache objectForKey:[NSNumber numberWithInt:mailinglistContact.recordID]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // get number of emails
        NSString *count = [NSString stringWithFormat:@"%ld contacts in group", (long)[mailinglistContact numberOfContactsInEmailField]];
        
        // if the value has been changed, update the cell
        if (![groupCount.text isEqualToString:count])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // if the cell is visible, then set the number
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    UILabel* groupCount = (UILabel*)[cell viewWithTag:102];
                    groupCount.text = count;
                }
            });
            [_emailCountCache setObject:count forKey:[NSNumber numberWithInt:mailinglistContact.recordID]];
        }
    });
    
    
    groupName.text = mailinglistContact.mailingListName;
    groupName.highlightedTextColor = [UIColor whiteColor];
    
    TOCK;
    /*
    if ((!kAppDelegate.premiumVersion) && (indexPath.row > 0))
    {
        UIImageView *overlay = (UIImageView *)[cell viewWithTag:9999];
        if (!overlay)
        {
            overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellOverlay.png"]];
            overlay.tag = 9999;
            [cell addSubview:overlay];
            [overlay bringSubviewToFront:cell.accessoryView];
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellOverlay_Indicator.png"]
                                                   highlightedImage:[UIImage imageNamed:@"MailingListCellOverlay_Selection_Indicator.png"]];
            cell.editingAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellOverlay_Indicator.png"]
                                                          highlightedImage:[UIImage imageNamed:@"MailingListCellOverlay_Selection_Indicator.png"]];

        }
    }
*/
    return cell;
}

- (void)loadContacts
{
    
//    if (!_contacts)
//        _contacts = [[NSMutableArray alloc] init];
//    else
//        [_contacts removeAllObjects];
//    
//    if (!_emails)
//        _emails = [[NSMutableArray alloc] init];
//    else
//        [_emails removeAllObjects];
    
    NSArray* emailAddresses;
    ABContact *currentML = _MLArray[_currentIndexPath.row];
    NSString *emailField = [currentML.emailaddresses stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (emailField.length)
        emailAddresses = [[NSArray alloc] initWithArray:[emailField componentsSeparatedByString:@">, \""]];
    
    if (!emailAddresses.count)
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
    
//    [self findContactsMatchingFullNameAndFillArrays:contactsNames andEmails:contactsEmails];
    
    [self sortContactsWith:([ABContactsHelper firstNameSorting] ? kMLSortUsingFirstName : kMLSortUsingLastName)];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_MLArray.count == 0)
        return NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _currentIndexPath = indexPath;
        [self deleteConfirmation];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentIndexPath = indexPath;

    if (_thumbnailTapped)       // users tapped on image to change thumbnail, don't select any row
    {
        _thumbnailTapped = NO;
        return;
    }
    if ((!kAppDelegate.premiumVersion) && (indexPath.row > 0)) {
        [self freeVersionAlert:@"NoOfGroupsExceed"];
        return;
    }
    
    [self optionsButtonTapped:self];
    _currentIndexPath = indexPath;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *takePhoto = nil;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            takePhoto = @"Take Photo";
        
        UIActionSheet *editGroupOptions = [[UIActionSheet alloc] initWithTitle:@"Group Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Group" otherButtonTitles:@"Compose New Email", @"Rename Group", @"Choose Existing Photo", takePhoto, nil];
        
        editGroupOptions.tag = 101;
        [editGroupOptions showFromToolbar:self.navigationController.toolbar];
    }
}



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([self.tableView isEditing])
        return NO;
    
    _currentIndexPath = [self.tableView indexPathForSelectedRow];
    if ((!kAppDelegate.premiumVersion) && (_currentIndexPath.row > 0))
        return NO;

    return YES;
}

#pragma ActionSheet

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 103)
    {
        if (buttonIndex == actionSheet.cancelButtonIndex)
            return;
        
        
        NSArray *recepients;
        MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
        compose.mailComposeDelegate = self;
        
        recepients = [[_MLArray[_currentIndexPath.row] emailaddresses] componentsSeparatedByString:@", "];
        
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
    else
    {
        NSInteger caseNumber = buttonIndex;
        if (actionSheet.tag == 102)
        {
            caseNumber += 3;  // pickThumbnailImage actionsheet doesn't have delete & rename & compose Buttons, +3 to correct cases
        }
        
        switch (caseNumber) {
            case 0:             // Delete Group
                [self deleteConfirmation];
                break;
                
            case 1:             // Compose New Email
            {
                UIActionSheet *composeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Compose New Email" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"To:", @"Cc:", @"BCc:", nil];
                composeActionSheet.tag = 103;
                [composeActionSheet showFromToolbar:self.navigationController.toolbar];
            }
                break;
                
            case 2:             // Rename Group
                if (kAppDelegate.premiumVersion)
                    [self renameList];
                else
                    [self freeVersionAlert:@"Options"];
                break;
                
            case 3:             // Choose Existing Photo
            {
                if (kAppDelegate.premiumVersion)
                {
                    
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    imagePicker.allowsEditing = YES;
                    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
                    //    [imagePicker takePicture];
                    
                    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
                }
                else
                    [self freeVersionAlert:@"Options"];
            }
                break;
                
            case 4:             // Take photo (or cancel if camera is not available)
            {
                if (buttonIndex == actionSheet.cancelButtonIndex)
                    return;
                if (kAppDelegate.premiumVersion)
                {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePicker.allowsEditing = YES;
                    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
                    imagePicker.delegate = self;
                    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
                }
                else
                    [self freeVersionAlert:@"Options"];

            }
                break;
                
            default:
                break;
        }
    }
}

-(IBAction)pickThumbnailImage:(id)sender
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    UIButton *imageButton = (UIButton *)sender;
    CGPoint p = [self.view convertPoint:imageButton.center fromView:imageButton];
    _currentIndexPath = [self.tableView indexPathForRowAtPoint:p];

    
    _thumbnailTapped = YES;
    NSString *takePhoto = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        takePhoto = @"Take Photo";
    
    UIActionSheet *pickThumbnailPhoto = [[UIActionSheet alloc] initWithTitle:@"Assign Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing Photo", takePhoto, nil];
    pickThumbnailPhoto.tag = 102;
    
    [pickThumbnailPhoto showFromToolbar:self.navigationController.toolbar];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    [self.navigationController setToolbarHidden:YES animated:YES];

    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    [self.navigationController setToolbarHidden:YES animated:YES];

    eSoftContact *contact = [[eSoftContact alloc] initWithRecord:[_MLArray[_currentIndexPath.row] record]];
    contact.pictureID = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    [_thumbnailCache removeObjectForKey:[NSNumber numberWithInt:contact.RecordID]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMLContacts"]) {
        _currentIndexPath = [self.tableView indexPathForSelectedRow];
        
        ABContact *currentML = _MLArray[_currentIndexPath.row];
        ListContactsViewController *listcvc = [segue destinationViewController];
        
        NSDictionary *currentMailingList = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            (__bridge id)currentML.record , ksABRecordRef,
                                            currentML.firstname, ksFirstName,
                                            currentML.lastname, ksLastName,
                                            currentML.emailaddresses, ksEmailAddresses,
                                            nil];
        listcvc.currentML = currentML;
        listcvc.currentMailingList = [currentMailingList mutableCopy];
        listcvc.currentRecordID = currentML.recordID;
        listcvc.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"Settings"]) {
        SettingsViewController *settings = [segue destinationViewController];
        settings.productID = @"com.designbymax.MailingLists.prem";
        [[SKPaymentQueue defaultQueue] addTransactionObserver:settings];

        [settings getProductID:self];
        
    }
}

#pragma mark IAP Methods

-(void)Purchased
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:kPremiumIntValue forKey:kPremium];
    [ud synchronize];
    kAppDelegate.premiumVersion = YES;

}


#pragma mark PageViewController Methods


-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIButton *dismissButton = (UIButton *)[self.pageViewController.view viewWithTag:1008];
    [UIView animateWithDuration:0.2 animations:^{
        dismissButton.alpha = 0;
    }];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
//        NSUInteger index = ((PageContentViewController*) previousViewControllers[0]).pageIndex;

//        NSLog(@"previous view contorllers: %@", previousViewControllers[0]);

        UIButton *dismissButton = (UIButton *)[self.pageViewController.view viewWithTag:1008];
        dismissButton.alpha = 1;
    }

}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];

    if([UIScreen mainScreen].bounds.size.height == 568)    // iPhone 4"
        pageContentViewController.imageFile = self.pageImages[index];
    else
        pageContentViewController.imageFile = self.pageImages_3_5[index];


    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{

    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    UIButton *dismissButton = (UIButton *)[self.navigationController.view viewWithTag:1008];

    if (index != self.pageTitles.count - 1)
    {
        dismissButton.frame = CGRectMake(262, 38, 40, 40);
        [dismissButton setImage:[UIImage imageNamed:@"CloseButton"] forState:UIControlStateNormal];
        [dismissButton setImage:[UIImage imageNamed:@"CloseButton_Highlighted"] forState:UIControlStateHighlighted];
    }
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;

    UIButton *dismissButton = (UIButton *)[self.pageViewController.view viewWithTag:1008];

    if (index == self.pageTitles.count - 1)
    {
        [dismissButton setImage:[UIImage imageNamed:@"OKButton.png"] forState:UIControlStateNormal];
        [dismissButton setImage:[UIImage imageNamed:@"OKButton_Selected.png"] forState:UIControlStateHighlighted];
        CGRect frame = dismissButton.frame;
        CGPoint center = dismissButton.center;
        

        frame.size.height = 31.0f;
        frame.size.width  = 140.0f;
        center.x = 160.0f;
        center.y = [UIScreen mainScreen].bounds.size.height - 80;

        dismissButton.frame = frame;
        dismissButton.center = center;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }

    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end






