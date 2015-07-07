
//
//  eSoftContact.m
//  Birthday
//
//  Created by Hadi Sharghi on ۹۰/۲/۳۰.
//  Copyright ۱۳۹۰ __MyCompanyName__. All rights reserved.
//

#import "eSoftContact.h"
#import <UIKit/UIKit.h>



// ABContact.m
@implementation eSoftContact

@synthesize addToUpcomingList;

#pragma mark - Init

- (id)initWithRecord:(ABRecordRef)aRecord;
{
    if ((self = [super init])){
        _record = CFRetain(aRecord);
        addToUpcomingList = YES;
    }
    return self;
}

#pragma mark - Getter

- (ABRecordRef) RecordRef {
    return _record;
}

- (ABRecordID) RecordID
{
    return ABRecordGetRecordID(_record);
}

- (NSString *) fullName {
    NSMutableString *full = [[[NSMutableString alloc] initWithString:self.firstName] autorelease];
    [full appendString:@" "];
    [full appendString:self.lastName];
    
    return (NSString *)full;
}

- (UIImage *) pictureID {
    
    NSData *imageData = (NSData *)CFBridgingRelease(ABPersonCopyImageDataWithFormat(_record, kABPersonImageFormatThumbnail));
    if (imageData != nil)
    {
        UIImage *im = [[[UIImage alloc] initWithData:(NSData*) imageData] autorelease];
        return im;
    }
    
    return nil;
}

- (NSDate *)birthday
{   
    return (NSDate *) CFBridgingRelease(ABRecordCopyValue(_record, kABPersonBirthdayProperty));
}

- (void) setBirthday: (NSDate*)date {
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef ref  = ABAddressBookGetPersonWithRecordID(iPhoneAddressBook, ABRecordGetRecordID(_record));
    CFErrorRef anError = NULL;
    
    //    NSString *fname = [[NSString alloc] init];
    //    fname = (NSString*) ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    
    ABRecordSetValue(ref, kABPersonBirthdayProperty, (CFDateRef)date, &anError);
    if (anError) { /* Handle error */ }
    
    if (ABAddressBookSave(iPhoneAddressBook, &anError) == true)
        NSLog(@"save shod");
    
    CFRelease(iPhoneAddressBook);
}

- (void) setPictureID:(UIImage *)pictureID {
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef ref  = ABAddressBookGetPersonWithRecordID(iPhoneAddressBook, ABRecordGetRecordID(_record));
    CFErrorRef anError = NULL;
    
    NSData *imageData = UIImagePNGRepresentation(pictureID);
    ABPersonSetImageData(ref, (__bridge CFDataRef)imageData, &anError);
    
    if (anError) { /* Handle error */ }
    
    if (ABAddressBookSave(iPhoneAddressBook, &anError) == true)
        NSLog(@"save shod");
    
    CFRelease(iPhoneAddressBook);
}

- (void) setThumbnailImage:(UIImage *)thumbnailImage
{
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef ref  = ABAddressBookGetPersonWithRecordID(iPhoneAddressBook, ABRecordGetRecordID(_record));
    CFErrorRef anError = NULL;
    
    NSData *imageData = UIImagePNGRepresentation(thumbnailImage);
    ABPersonSetImageData(ref, (__bridge CFDataRef)imageData, &anError);
    
    if (anError) { /* Handle error */ }
    
    if (ABAddressBookSave(iPhoneAddressBook, &anError) == true)
        NSLog(@"save shod");
    
    CFRelease(iPhoneAddressBook);
}

- (NSDictionary *)dates {
    NSMutableArray* arrayValues = [[NSMutableArray alloc] init];
    NSMutableArray* arrayKeys = [[NSMutableArray alloc] init];
    
    ABMultiValueRef mv = ABRecordCopyValue(_record, kABPersonDateProperty);
    if (mv == NULL)
    {
        [arrayKeys release];
        [arrayValues release];
        return nil;
    }
    
    for (int i=0; i<ABMultiValueGetCount(mv); i++)
    {
        [arrayValues addObject:(__bridge NSDate*)CFAutorelease(ABMultiValueCopyValueAtIndex(mv, i))];
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(CFAutorelease(ABMultiValueCopyLabelAtIndex(mv, i)));
        [arrayKeys addObject:(__bridge NSString*)localizedLabel];
        CFRelease(localizedLabel);
    }
    NSDictionary* dic = [[[NSDictionary alloc] initWithObjects:(NSArray*) arrayValues forKeys:(NSArray*)arrayKeys] autorelease];
    CFRelease(mv);
    [arrayValues release];
    [arrayKeys release];
    
    return dic;
}

- (void) setDates:(NSDictionary*)dates {
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef ref  = ABAddressBookGetPersonWithRecordID(iPhoneAddressBook, ABRecordGetRecordID(_record));
    CFErrorRef anError = NULL; 
    ABMutableMultiValueRef multiDate = ABMultiValueCreateMutable(kABMultiDateTimePropertyType);
    NSArray* values = [[NSArray alloc] initWithArray:[dates allValues]];
    NSArray* keys   = [[NSArray alloc] initWithArray:[dates allKeys]];
    
    for (int i=0; i<[dates count]; i++) {
//        NSDate* d = [[NSDate alloc] init];
//        NSString* s = [[NSString alloc] init];
        
        NSDate *d = (NSDate*) [values objectAtIndex:i];
        NSString *s= (NSString*) [keys objectAtIndex:i];
        
        ABMultiValueAddValueAndLabel(multiDate, (CFDateRef) CFBridgingRetain(d), (CFStringRef) CFBridgingRetain(s), NULL);
        
        [d release];
        [s release];
    }
    
    [values release];
    [keys release];
    
    ABRecordSetValue(ref, kABPersonDateProperty, multiDate, &anError);
    if (anError) { /* Handle error */ } 
    
    if (ABAddressBookSave(iPhoneAddressBook, &anError) == true)
        NSLog(@"save shod");
    
    CFRelease(iPhoneAddressBook);
    CFRelease(multiDate);
    
}

- (void) setEmails:(NSDictionary *)emails {
    
//    NSLog(@"\nemails before setEmails: %@",[self emails]);
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef ref  = ABAddressBookGetPersonWithRecordID(iPhoneAddressBook, ABRecordGetRecordID(_record));
    CFErrorRef anError = NULL; 
    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABPersonEmailProperty);
    NSArray* values = [[NSArray alloc] initWithArray:[emails allValues]];
    NSArray* keys   = [[NSArray alloc] initWithArray:[emails allKeys]];


    for (int i=0; i<[emails count]; i++) {
//        NSString* address = [[NSString alloc] init];
//        NSString* label   = [[NSString alloc] init];
        
        NSString* label   = (NSString *) [values objectAtIndex:i];
        NSString* address = (NSString *) [keys objectAtIndex:i];
        
        ABMultiValueAddValueAndLabel(multiEmail, (CFDateRef) CFBridgingRetain(label), (CFStringRef) CFBridgingRetain(address), NULL);
        
        [label release];
        [address release];
    }
    
    [values release];
    [keys release];
    
    ABRecordSetValue(ref, kABPersonEmailProperty, multiEmail, &anError);
    if (anError) { /* Handle error */ } 
    
    if (ABAddressBookSave(iPhoneAddressBook, &anError) == true)
        NSLog(@"save shod");
    
    CFRelease(iPhoneAddressBook);
    CFRelease(multiEmail);
//    NSLog(@"\nemails after setEmails: %@",[self emails]);

    
}

- (NSString *)firstName
{
    CFTypeRef fName = ABRecordCopyValue(_record, kABPersonFirstNameProperty);
    
    if (fName == NULL)
        return @"";

    CFAutorelease(fName);
    return (__bridge NSString *)fName;
}

- (NSString *)lastName
{
    CFTypeRef lName = ABRecordCopyValue(_record, kABPersonLastNameProperty);
    
    if (lName == NULL)
        return @"";

    CFAutorelease(lName);
    return (__bridge NSString *)lName;
}

- (NSDictionary*) emails
{
    NSMutableDictionary *multiEmail = [[[NSMutableDictionary alloc] init] autorelease];
    
    ABMutableMultiValueRef multi = ABRecordCopyValue(_record, kABPersonEmailProperty);
    if (multi == NULL)
        return nil;

    for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++)
    {
        CFStringRef email = ABMultiValueCopyValueAtIndex(multi, i);
        CFStringRef emailLable = ABMultiValueCopyLabelAtIndex(multi, i);
        CFStringRef localizedEmailLable = ABAddressBookCopyLocalizedLabel(emailLable);
        
        [multiEmail setValue:(__bridge NSString *)email forKey:(__bridge NSString *)emailLable];
        
        CFRelease(email);
        CFRelease(emailLable);
        CFRelease(localizedEmailLable);
    }
    
    CFRelease(multi);
    return (NSDictionary*) multiEmail;
}

- (NSDictionary*) phones
{
    NSMutableDictionary *multiPhone = [[[NSMutableDictionary alloc] init] autorelease];
    
    ABMutableMultiValueRef multi = ABRecordCopyValue(_record, kABPersonPhoneProperty);
    
    if (multi == NULL)
        return nil;

    for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++)
    {
        CFStringRef phone = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, i);
        CFStringRef phoneLabel = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, i);
        CFStringRef localizedPhoneLabel = ABAddressBookCopyLocalizedLabel(phoneLabel);
        
        [multiPhone setValue:(__bridge NSString *)phone forKey:(__bridge NSString *)phoneLabel];
        
        CFRelease(phone);
        CFRelease(phoneLabel);
        CFRelease(localizedPhoneLabel);
    }
    
    CFRelease(multi);
    
    return (NSDictionary*) multiPhone;
    
}

#pragma mark - Memory management

- (void)dealloc
{
    if (_record)
        CFRelease(_record);
    
    [super dealloc];
}

@end
