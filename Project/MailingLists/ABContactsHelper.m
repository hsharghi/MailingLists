/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */
#import "ABContactsHelper.h"
#import <Crashlytics/Crashlytics.h>

@implementation ABContactsHelper
/*
 Note: You cannot CFRelease the addressbook after ABAddressBookCreate();
 */
+ (ABAddressBookRef) addressBook
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFAutorelease(addressBook);
    return addressBook;
}
+ (NSArray *) contacts
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *thePeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
    for (id person in thePeople)
        [array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
    
    CFRelease(addressBook);
    
    return array;
}
+ (int) contactsCount
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    int personCount = (int)ABAddressBookGetPersonCount(addressBook);
    CFRelease(addressBook);
    return personCount;
}
+ (NSArray *) contactsWithEmail
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSMutableArray *peopleWithEmail = [[[NSMutableArray alloc] initWithCapacity:peopleArray.count] autorelease];
    for (id person in peopleArray)
    {
        ABMutableMultiValueRef email = ABRecordCopyValue(CFBridgingRetain(person), kABPersonEmailProperty);
        if (ABMultiValueGetCount(email) > 0)
            [peopleWithEmail addObject:(id)person];
        
        CFRelease(person);
        if (email) CFRelease(email);
    }
    
    CFRelease(addressBook);

    return (NSArray *)peopleWithEmail;
}
+ (int) contactsWithImageCount
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    int ncount = 0;
    for (id person in peopleArray){
        if (ABPersonHasImageData(CFBridgingRetain(person)))
            ncount++;
        CFRelease(person);
    }
    CFRelease(addressBook);
    return ncount;
}
+ (int) contactsWithoutImageCount
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    int ncount = 0;
    for (id person in peopleArray) {
        if (!ABPersonHasImageData(CFBridgingRetain(person)))
            ncount++;
        
        CFRelease(person);
    }
    CFRelease(addressBook);
    return ncount;
}
// Groups
+ (NSUInteger) numberOfGroups
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *groups = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllGroups(addressBook));
    NSUInteger ncount = groups.count;
    CFRelease(addressBook);
    return ncount;
}
+ (NSArray *) groups
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *groups = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllGroups(addressBook));
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:groups.count];
    for (id group in groups)
    {
        [array addObject:[ABGroup groupWithRecord:(ABRecordRef)group]];
        CFRelease(group);
    }
    CFRelease(addressBook);
    return array;
}
// Sorting
+ (BOOL) firstNameSorting
{
    return (ABPersonGetCompositeNameFormatForRecord(NULL) == kABPersonCompositeNameFormatFirstNameFirst);
}
#pragma mark Contact Management
// Thanks to Eridius for suggestions re: error
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error
{
    
    BOOL ret;
    CFErrorRef cfError;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);

    if (!ABAddressBookAddRecord(addressBook, aContact.record, &cfError))
    {
        NSString *err = (NSString *) CFErrorCopyDescription(cfError);
        [Crashlytics setObjectValue:err forKey:@"addContact (error:)"];

        if (addressBook)
            CFRelease(addressBook);
        
        return NO;
    }
    ret = ABAddressBookSave(addressBook, &cfError);
    if (!ret && error)
        *error = CFBridgingRelease(cfError);
    
    if (addressBook) CFRelease(addressBook);
    return ret;
    
//    
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    if (!ABAddressBookAddRecord(addressBook, aContact.record, (CFErrorRef *) error)) return NO;
//    return ABAddressBookSave(addressBook, (CFErrorRef *) error);
}
+ (BOOL) addGroup: (ABGroup *) aGroup withError: (NSError **) error
{
    
    BOOL ret;
    CFErrorRef cfError;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    if (!ABAddressBookAddRecord(addressBook, aGroup.record, &cfError))
    {
        CFRelease(addressBook);
        return NO;
    }
    ret = ABAddressBookSave(addressBook, &cfError);

    if (!ret && error)
        *error = CFBridgingRelease(cfError);
    
    CFRelease(addressBook);
    return ret;
    
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    if (!ABAddressBookAddRecord(addressBook, aGroup.record, (CFErrorRef *) error)) return NO;
//    return ABAddressBookSave(addressBook, (CFErrorRef *) error);
}
+ (NSArray *) contactsMatchingName: (NSString *) fname
{
    NSPredicate *pred;
    NSArray *contacts = [ABContactsHelper contacts];
//    NSString *predicate = [NSString stringWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@ OR organization contains[cd] %@", fname, fname, fname, fname, fname];
    
    pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@ OR organization contains[cd] %@", fname, fname, fname, fname, fname];
    return [contacts filteredArrayUsingPredicate:pred];
}
+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname
{
    NSPredicate *pred;
    NSArray *contacts = [ABContactsHelper contacts];
    pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", lname, lname, lname, lname];
    contacts = [contacts filteredArrayUsingPredicate:pred];
    return contacts;
}
+ (NSArray *) contactsMatchingPhone: (NSString *) number
{
    NSPredicate *pred;
    NSArray *contacts = [ABContactsHelper contacts];
    pred = [NSPredicate predicateWithFormat:@"phonenumbers contains[cd] %@", number];
    return [contacts filteredArrayUsingPredicate:pred];
}
+ (NSArray *) groupsMatchingName: (NSString *) fname
{
    NSPredicate *pred;
    NSArray *groups = [ABContactsHelper groups];
    pred = [NSPredicate predicateWithFormat:@"name contains[cd] %@ ", fname];
    return [groups filteredArrayUsingPredicate:pred];
}
+ (NSArray *) mailigLists: (NSString *) mailingaListIdentifier
{
    NSPredicate *pred;
    NSArray *contacts = [ABContactsHelper contacts];
    pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR organization contains[cd] %@", mailingaListIdentifier, mailingaListIdentifier, mailingaListIdentifier];
    contacts = [contacts filteredArrayUsingPredicate:pred];
    return contacts;
}

@end