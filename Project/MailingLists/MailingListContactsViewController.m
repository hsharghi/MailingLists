//
//  DetailViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۶ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "MailingListContactsViewController.h"

@interface MailingListContactsViewController (){
    NSMutableArray *_contacts;
    NSMutableArray *_emails;

}
- (void)configureView;
@end

@implementation MailingListContactsViewController


#pragma mark - Managing the detail item

- (void)loadContacts
{
    if (!_contacts)
        _contacts = [[NSMutableArray alloc] init];
    else
        [_contacts removeAllObjects];
    
    if (_emails)
        _emails = [[NSMutableArray alloc] init];
    else
        [_emails removeAllObjects];
    
    
    NSArray* emailsTest = [[NSArray alloc] initWithArray:
                           [_currentML.emailaddresses componentsSeparatedByString:@">, \""]];
    
    
    for (__strong NSString* e in emailsTest)
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
    
        [_contacts addObject:[self findContactsMatchingFullName:name]];
        [_emails addObject:address];
        
    }
    
    
    [self sortContactsWith:([ABContactsHelper firstNameSorting] ? kMLSortUsingFirstName : kMLSortUsingLastName)];
    
    
}

- (void) sortContactsWith:(sortDescriptor)descriptor
{
    NSMutableArray *sortName = [NSMutableArray array];

    if (descriptor == kMLSortUsingFirstName)
        for (ABContact *c in _contacts)
        {
            [sortName removeAllObjects];
            [sortName addObject:c.firstname];
        }
    else if (descriptor == kMLSortUsingLastName)
        for (ABContact *c in _contacts)
        {
            [sortName removeAllObjects];
            [sortName addObject:c.lastname];
        }
    
    NSMutableArray *combined = [NSMutableArray array];
    
    
    for (NSUInteger i = 0; i < _contacts.count; i++) {
        [combined addObject: @{@"sortName" : sortName[i], @"ABContact": _contacts[i], @"email": _emails[i]}];
    }
    
    [combined sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortName" ascending:YES]]];
    
    [_contacts removeAllObjects];
    [_emails removeAllObjects];
    _contacts = [combined valueForKey:@"ABContact"];
    _emails   = [combined valueForKey:@"email"];
    
    NSLog(@"_contacts: %@\nl_emails: %@", _contacts, _emails);
    
}

- (ABContact *) findContactsMatchingFullName:(NSString *)fullName {
    NSArray *nameParts = [[NSArray alloc] initWithArray:[fullName componentsSeparatedByString:@" "]];
    
    NSArray *allContacts = [ABContactsHelper contactsMatchingName:[nameParts objectAtIndex:0]];
    //    NSPredicate *pred;
    
    for (ABContact *rec in allContacts)
    {
        NSString *name = [rec.firstname stringByAppendingFormat:@" %@", rec.lastname];
        if ([name isEqualToString:fullName])
            return rec;
    }
    return nil;
}


- (void)setCurrentML:(ML*)MList
{
    if (_currentML != MList)
    {
        _currentML = MList;
        [self loadContacts];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
//
//    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [self.detailItem description];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self configureView];
    [self loadContacts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
