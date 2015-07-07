//
//  PasteGroupViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۲/۲۲ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "PasteGroupViewController.h"

@interface PasteGroupViewController () {
    NSMutableArray *_contacts;
    NSMutableArray *_emails;
}

@end

@implementation PasteGroupViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (!_contacts)
        _contacts = [[NSMutableArray alloc] init];
    else
        [_contacts removeAllObjects];
    
    if (!_emails)
        _emails = [[NSMutableArray alloc] init];
    else
        [_emails removeAllObjects];
    
    _listOfEmails.layer.borderWidth = 1.0f;
    _listOfEmails.layer.borderColor = [[UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1] CGColor];
    if([UIScreen mainScreen].bounds.size.height == 568)    // iPhone 4"
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 60);
    else    // iPhone 3.5"
    {
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 160);
        CGRect frame = _listOfEmails.frame;
        frame.size.height -= 65;
        _listOfEmails.frame = frame;
        frame = _pasteButton.frame;
        frame.origin.y -= 65;
        _pasteButton.frame = frame;
        
        frame = _clearButton.frame;
        frame.origin.y -= 65;
        _clearButton.frame = frame;

        frame = _descriptionLabel.frame;
        frame.origin.y -= 65;
        _descriptionLabel.frame = frame;
}
//    [_scrollView scrollRectToVisible:CGRectMake(0, 140, 320, 400) animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (ABRecordID)findContactWithEmail:(NSString *)emailAddress inArray:(NSArray *)allContacts
{
    for (NSDictionary *contactDic in allContacts)
        for (NSString *email in [contactDic valueForKey:ksEmailsArray])
            if ([emailAddress isEqualToString:email])
                return (ABRecordID)[contactDic valueForKey:ksABRecordID];
    
    return -1;
}

*/

- (void)freeVersionAlert:(NSString *)source
{
    if ([source isEqualToString:@"savePaste"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limited Version" message:@"This feature is not availbale in free version. Please purchase Premium version." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        alert.tag = 6;
        alert.delegate = self;
        [alert show];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
        return;
    else
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        NSLog(@"views: %@", viewControllers);
        MailingListViewController *rootViewController = (MailingListViewController*)[viewControllers objectAtIndex:0];
        [rootViewController performSegueWithIdentifier:@"Settings" sender:self];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL) checkStringFormat:(NSString *)string
{
    BOOL check = YES;
    NSRange r1 = [string rangeOfString:@"<"];
    NSRange r2 = [string rangeOfString:@">"];
    if (r1.location == NSNotFound)
        check = NO;
    else if (r2.location == NSNotFound)
        check = NO;
    
    return check;
}

- (void) formatIsNotAccepted
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Format" message:@"Text is not within specified format. Please correct format and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)pasteFromClipboard:(id)sender {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteItem = pasteboard.string;
    
    if (pasteItem != nil) {
        NSLog(@"paste: %@", pasteItem);
        _listOfEmails.text = pasteItem;
    }

}

- (IBAction)clearContents:(id)sender {
    _listOfEmails.text = @"";
}

- (IBAction)tapTokhmi:(id)sender {
    NSLog(@"TAPPED");
    [self.listOfEmails resignFirstResponder];
}

- (IBAction)saveList:(id)sender {
    
    // remove the limitation on import contacts manually in free version
    
//    if (!kAppDelegate.premiumVersion)
//    {
//        [self freeVersionAlert:@"savePaste"];
//        return;
//    }
    
    NSMutableArray* emailAddresses;
    NSString *emailField = [_listOfEmails.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    emailField = [emailField stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSCharacterSet *space = [NSCharacterSet whitespaceCharacterSet];
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];

    if (emailField.length)
    {
        emailField = [regex stringByReplacingMatchesInString:emailField
                                                     options:0
                                                       range:NSMakeRange(0, [emailField length])
                                                withTemplate:@" "]; // remove more than 1 space in string
        emailField = [emailField stringByReplacingOccurrencesOfString:@"> " withString:@">"];
        emailField = [emailField stringByReplacingOccurrencesOfString:@">, " withString:@">,"];
        emailAddresses = [[NSMutableArray alloc] initWithArray:[emailField componentsSeparatedByString:@">,"]];
        for (int i = 0; i < emailAddresses.count; i++)
        {
            NSString *e = emailAddresses[i];
            if (![[e substringFromIndex:e.length-1]  isEqual: @">"])
                emailAddresses[i] = [e stringByAppendingString:@">"];
        }
        
                
                
    }
    
    if (![self checkStringFormat:emailField])
    {
        [self formatIsNotAccepted];
        return;
    }
    
    for (__strong NSString* e in emailAddresses)    //extract email addresses and name from pasted text
    {
        if (![self checkStringFormat:e])
        {
            [self formatIsNotAccepted];
            return;
        }
        
        NSString *name, *email;
        if (![[e substringFromIndex:e.length-2] isEqualToString:@">"])
        {
            name  = [[e substringToIndex:[e rangeOfString:@"<"].location] stringByTrimmingCharactersInSet:space];
            email = [[e substringFromIndex:[e rangeOfString:@"<"].location+1] stringByTrimmingCharactersInSet:space];
        }
        if (![name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
            name = @"No Name";
        if (![[name substringToIndex:1] isEqualToString:@"\""])
            name = [@"\"" stringByAppendingString:name];
        if (![[name substringFromIndex:[name length]-1] isEqualToString:@"\""])
            name = [name stringByAppendingString:@"\""];
        if ([[email substringFromIndex:email.length-1] isEqualToString:@">"])
            email = [email substringToIndex:email.length-1];
        
        NSLog(@"Name: %@\nEmail: %@", name, email);
        
        if ([self NSStringIsValidEmail:email])
        {
            NSDictionary *contact = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     name, ksFullName,
                                     email, ksEmailAddresses,
                                     nil];
            [_contacts addObject:contact];
        }
        else
        {
            [self formatIsNotAccepted];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate getBackPastedContacts:_contacts];

}
@end
