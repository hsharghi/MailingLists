//
//  UnnamedContactsViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۳/۷/۵ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "UnnamedContactsViewController.h"
#import "UnnamedContactTableViewCell.h"
#import "ABContact.h"
#import <AddressBookUI/AddressBookUI.h>

@interface UnnamedContactsViewController ()

@end

@implementation UnnamedContactsViewController

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
    
    self.title = @"Unnamed contacts";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.tableView registerClass:[UnnamedContactTableViewCell class] forCellReuseIdentifier:@"UnnamedContactCell"];
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
    return self.unnamedContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"UnnamedContactCell";
//    UnnamedContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UnnamedContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnnamedContactCell"];
    if (!cell)
        cell = [[UITableViewCell alloc] init];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor colorWithRed:241/255.0 green:250/255.0 blue:254/255.0 alpha:1];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellBG_Indicator.png"]
                                           highlightedImage:[UIImage imageNamed:@"MailingListCellBG_Selection_Indicator.png"]];
    cell.editingAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MailingListCellBG_Indicator.png"]
                                                  highlightedImage:[UIImage imageNamed:@"MailingListCellBG_Selection_Indicator.png"]];
    
    UIView *selectedBGView = [[UIView alloc] init];
    selectedBGView.backgroundColor = [UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1];
    cell.selectedBackgroundView = selectedBGView;

    
    ABContact *contact = [ABContact contactWithRecord:(__bridge ABRecordRef)(self.unnamedContacts[indexPath.row])];
    
    NSLog(@"contact phone string: %@\ncontact email string: %@\n", contact.phonenumbers, contact.emailaddresses);
    NSLog(@"contact phones: %@\ncontact labels: %@\n", contact.phoneArray, contact.phoneLabels);
    UIImageView *thumbnail = (UIImageView *)[cell viewWithTag:1000];
    UILabel *phoneNumber = (UILabel *)[cell viewWithTag:1001];
    UILabel *phoneLabel = (UILabel *)[cell viewWithTag:1002];
    UILabel *emailAddress = (UILabel *)[cell viewWithTag:1003];
    UILabel *emailLabel = (UILabel *)[cell viewWithTag:1004];
    if (contact.phoneArray.count)
    {
        phoneNumber.text = contact.phoneArray[0];
        phoneLabel.text  = contact.phoneLabels[0];
    }
    else
    {
        phoneNumber.text = @"No Phone Number";
        phoneLabel.text  = @"";
    }
    
    if (contact.emailArray.count)
    {
        emailAddress.text = contact.emailArray[0];
        emailLabel.text  = contact.emailLabels[0];
    }
    else
    {
        emailAddress.text = @"No email address";
        emailLabel.text  = @"";
    }
    
    UIImage *image = contact.thumbnail;
    if (!image) {
        image = [UIImage imageNamed:@"noPictureID.png"];
    }

    thumbnail.image = image;
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UILabel *phone = (UILabel *)[cell viewWithTag:1001];
//    UILabel *email = (UILabel *)[cell viewWithTag:1003];
//    
//    phone.textColor = [UIColor whiteColor];
//    email.textColor = [UIColor whiteColor];
    
    ABPersonViewController *abperson = [[ABPersonViewController alloc] init];
    abperson.displayedPerson = (__bridge ABRecordRef)(_unnamedContacts[indexPath.row]);
    abperson.allowsActions = NO;
    abperson.allowsEditing = YES;
    NSArray *displayProperties = [NSArray arrayWithObjects:
                                  [NSNumber numberWithInt:kABPersonFirstNameProperty],
                                  [NSNumber numberWithInt:kABPersonLastNameProperty],
                                  [NSNumber numberWithInt:kABPersonOrganizationProperty],
                                  [NSNumber numberWithInt:kABPersonPhoneProperty],
                                  [NSNumber numberWithInt:kABPersonEmailProperty],
                                  nil];
    abperson.displayedProperties = displayProperties;
    
    [self.navigationController pushViewController:abperson animated:YES];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
