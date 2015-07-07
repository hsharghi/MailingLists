/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */
#import "ABGroup.h"
#import "ABContactsHelper.h"
@implementation ABGroup
@synthesize record;
// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init]) record = CFRetain(aRecord);
    return self;
}
+ (id) groupWithRecord: (ABRecordRef) grouprec
{
    return [[[ABGroup alloc] initWithRecord:grouprec] autorelease];
}
+ (id) groupWithRecordID: (ABRecordID) recordID
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef grouprec = ABAddressBookGetGroupWithRecordID(addressBook, recordID);
    CFRelease(addressBook);
    ABGroup *group = [self groupWithRecord:grouprec];
//    CFRelease(grouprec);
    return group;
}

// Thanks to Ciaran
+ (id) group
{
    ABRecordRef grouprec = ABGroupCreate();
    id group = [ABGroup groupWithRecord:grouprec];
    CFRelease(grouprec);
    return group;
}
- (void) dealloc
{
    if (record) CFRelease(record);
    [super dealloc];
}
- (BOOL) removeSelfFromAddressBook: (NSError **) error
{
    
    BOOL ret;
    CFErrorRef cfError;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    if (!ABAddressBookRemoveRecord(addressBook, self.record, &cfError))
    {
        CFRelease(addressBook);
        return NO;
    }
    
    ret = ABAddressBookSave(addressBook, &cfError);
    CFRelease(addressBook);
    
    if (!ret && error)
        *error = CFBridgingRelease(cfError);
    return ret;
    
    
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    if (!ABAddressBookRemoveRecord(addressBook, self.record, (CFErrorRef *) error)) return NO;
//    return ABAddressBookSave(addressBook,  (CFErrorRef *) error);
}
#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}
#pragma mark management
- (NSArray *) members
{
    NSArray *contacts = (NSArray *)CFBridgingRelease(ABGroupCopyArrayOfAllMembers(self.record));
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
    for (id contact in contacts)
        [array addObject:[ABContact contactWithRecord:(ABRecordRef)contact]];
    return array;
}
// kABPersonSortByFirstName = 0, kABPersonSortByLastName  = 1
- (NSArray *) membersWithSorting: (ABPersonSortOrdering) ordering
{
    NSArray *contacts = (NSArray *)CFBridgingRelease(ABGroupCopyArrayOfAllMembersWithSortOrdering(self.record, ordering));
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
    for (id contact in contacts)
        [array addObject:[ABContact contactWithRecord:(ABRecordRef)contact]];
    return array;
}
- (BOOL) addMember: (ABContact *) contact withError: (NSError **) error
{    
    return ABGroupAddMember(self.record, contact.record, NULL);
}
- (BOOL) removeMember: (ABContact *) contact withError: (NSError **) error
{
    return ABGroupRemoveMember(self.record, contact.record, NULL);
}
#pragma mark name
- (NSString *) getRecordString:(ABPropertyID) anID
{
    return (NSString *) CFBridgingRelease(ABRecordCopyValue(record, anID));
}
- (NSString *) name
{
    NSString *string = (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(record));
    return string;
}
- (void) setName: (NSString *) aString
{
    CFErrorRef error;
    BOOL success = ABRecordSetValue(record, kABGroupNameProperty, (__bridge CFStringRef) aString, &error);
    if (!success) NSLog(@"Error: %@", [(NSError *)CFBridgingRelease(error) localizedDescription]);
    
}
@end