//
//  GroupMembersViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۱/۹ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "GroupMembersViewController.h"

@interface GroupMembersViewController ()

@property (nonatomic, strong) NSMutableArray *groupMembers;

@end

@implementation GroupMembersViewController

-(void)createContactsDictionaryWithRecords:(NSArray*)recordsArray
{
    if (!_groupMembers)
        _groupMembers = [[NSMutableArray alloc] init];
    else
        [_groupMembers removeAllObjects];
    
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
        
        if (!([fname isEqualToString:@""]) || !([lname isEqualToString:@""]) || !([organization isEqualToString:@""]))
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
            NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (id)person, ksABRecordRef,
                                     fname, ksFirstName,
                                     lname, ksLastName,
                                     mname, ksMiddleName,
                                     fullName, ksFullName,
                                     organization, ksOrganization,
                                     emailsArray, ksEmailsArray,
                                     (NSArray*)labelsArray , ksLabelsArray,
                                     nil];
            
            
            [_groupMembers addObject:contact];
        }
        
        CFRelease(emails);
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(addressbook, (ABRecordID)[[_currentGroup objectForKey:ksABRecordID] integerValue]);
    NSArray *contacts = (NSArray *)CFBridgingRelease(ABGroupCopyArrayOfAllMembersWithSortOrdering(groupRef, ABPersonGetSortOrdering()));
    [self createContactsDictionaryWithRecords:contacts];


    if (addressbook)
        CFRelease(addressbook);
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _groupMembers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MembersCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    cell.textLabel.text = [_groupMembers[indexPath.row] objectForKey:ksFullName];
    NSString *detailedText;
    switch ((int)[[_groupMembers[indexPath.row] objectForKey:ksEmailsArray] count])
    {
        case 0:
            detailedText = @"No email address";
            break;
            
        case 1:
            detailedText = [[_groupMembers[indexPath.row] objectForKey:ksEmailsArray] objectAtIndex:0];
            break;
            
        default:
            detailedText = [NSString stringWithFormat:@"%d email addresses", (int)[[_groupMembers[indexPath.row] objectForKey:ksEmailsArray] count]];
            break;
    }
    
    cell.detailTextLabel.text = detailedText;

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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
