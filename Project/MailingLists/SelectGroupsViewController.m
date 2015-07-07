//
//  MyTestViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۱/۹ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "SelectGroupsViewController.h"
#import "GroupMembersViewController.h"

@interface SelectGroupsViewController ()

@end

@implementation SelectGroupsViewController

@synthesize delegate;


- (void)loadAddressBookGroups
{
    if (!_groupsDictionary)
        _groupsDictionary = [[NSMutableArray alloc] init];
    
    [_groupsDictionary removeAllObjects];
    
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *groups = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllGroups(ab));
    for (id g in groups)
    {
        ABRecordID recordID = ABRecordGetRecordID((__bridge ABRecordRef) g);
        CFStringRef groupName = ABRecordCopyValue((__bridge ABRecordRef) g, kABGroupNameProperty);
        NSArray *groupMembers = CFBridgingRelease(ABGroupCopyArrayOfAllMembers((__bridge ABRecordRef) g));
        int membersCount = 0;
        int emailsCount = 0;
        for (id rec in groupMembers)    //check if member has email acccount
        {
            ABMultiValueRef emails = ABRecordCopyValue((__bridge ABRecordRef) rec, kABPersonEmailProperty);
            if (ABMultiValueGetCount(emails))
            {
                membersCount++;
                emailsCount += ABMultiValueGetCount(emails);
            }
            CFRelease(emails);
        }
    
        NSDictionary *group = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:(int)recordID], ksABRecordID,
                               (id)g, ksABRecordRef,
                               groupName, ksGroupName,
                               [NSNumber numberWithInt:membersCount], ksMembersCount,
                               [NSNumber numberWithInt:emailsCount], ksEmailsCount,
                               nil];
        [_groupsDictionary addObject:group];
        CFRelease(groupName);
    }
    NSSortDescriptor *groupSorter = [[NSSortDescriptor alloc] initWithKey:ksGroupName
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    [_groupsDictionary sortUsingDescriptors:@[groupSorter]];
    NSLog(@"groups dictionary: %@", _groupsDictionary);
    
    if (ab) CFRelease(ab);
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self loadAddressBookGroups];

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
    return _groupsDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    UILabel *groupName = (UILabel *)[cell viewWithTag:201];
    UILabel *groupMemberCount = (UILabel *)[cell viewWithTag:202];
    groupName.text = [_groupsDictionary[indexPath.row] valueForKey:ksGroupName];
    long members = [[_groupsDictionary[indexPath.row] valueForKey:ksMembersCount] integerValue];
    NSString *contact = (members > 1 ? @"Contacts" : @"Contact");
    long emailsCount = [[_groupsDictionary[indexPath.row] valueForKey:ksEmailsCount] integerValue];
    NSString *email = (emailsCount > 1 ? @"emails" : @"email");
    groupMemberCount.text = [NSString stringWithFormat:@"%ld %@, %ld %@ in group", members, contact, emailsCount, email];

    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate getBackGroup:_groupsDictionary[indexPath.row]];
    

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

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

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    GroupMembersViewController *vc = [segue destinationViewController];
    vc.currentGroup = _groupsDictionary[indexPath.row];
    vc.title        = [_groupsDictionary[indexPath.row] objectForKey:ksGroupName];
    
}


@end
