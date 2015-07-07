/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define mailingListIdentifier @"__MailingList"


@interface ABContact : NSObject
{
    ABRecordRef record;
}
// Convenience allocation methods
+ (id) contact;
+ (id) contactWithRecord: (ABRecordRef) record;
+ (id) contactWithRecordID: (ABRecordID) recordID;
// Class utility methods
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty;
+ (ABPropertyType) propertyType: (ABPropertyID) aProperty;
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty;
+ (NSString *) propertyString: (ABPropertyID) aProperty;
+ (BOOL) propertyIsMultivalue: (ABPropertyID) aProperty;
+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;
+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;
// Creating proper dictionaries
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label;
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
                           withState:(NSString *) state withZip: (NSString *) zip
                         withCountry: (NSString *) country withCode: (NSString *) code;
+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName;
// Instance utility methods
- (BOOL) removeSelfFromAddressBook: (NSError **) error;
- (NSInteger) numberOfContactsInEmailField; // MailingList utility
@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;
#pragma mark SINGLE VALUE STRING
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *middlename;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *firstnamephonetic;
@property (nonatomic, strong) NSString *lastnamephonetic;
@property (nonatomic, strong) NSString *middlenamephonetic;
@property (nonatomic, strong) NSString *organization;
@property (nonatomic, strong) NSString *jobtitle;
@property (nonatomic, strong) NSString *department;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSString *mailingListName; // MailingList utility
@property (strong, nonatomic, readonly) NSString *fullName; // MailingList utility
@property (strong, nonatomic, readonly) NSString *contactName; // my friendly utility
@property (strong, nonatomic, readonly) NSString *compositeName; // via AB
#pragma mark DATE
@property (nonatomic, strong) NSDate *birthday;
@property (strong, nonatomic, readonly) NSDate *creationDate;
@property (strong, nonatomic, readonly) NSDate *modificationDate;
#pragma mark MULTIVALUE
// Each of these produces an array of NSStrings
@property (strong, nonatomic, readonly) NSArray *emailArray;
@property (strong, nonatomic, readonly) NSArray *emailLabels;
@property (strong, nonatomic, readonly) NSArray *phoneArray;
@property (strong, nonatomic, readonly) NSArray *phoneLabels;
@property (strong, nonatomic, readonly) NSArray *relatedNameArray;
@property (strong, nonatomic, readonly) NSArray *relatedNameLabels;
@property (strong, nonatomic, readonly) NSArray *urlArray;
@property (strong, nonatomic, readonly) NSArray *urlLabels;
@property (strong, nonatomic, readonly) NSArray *dateArray;
@property (strong, nonatomic, readonly) NSArray *dateLabels;
@property (strong, nonatomic, readonly) NSArray *addressArray;
@property (strong, nonatomic, readonly) NSArray *addressLabels;
@property (strong, nonatomic, readonly) NSArray *smsArray;
@property (strong, nonatomic, readonly) NSArray *smsLabels;
@property (strong, nonatomic, readonly) NSString *emailaddresses;
@property (strong, nonatomic, readonly) NSString *phonenumbers;
@property (strong, nonatomic, readonly) NSString *urls;
// Each of these uses an array of dictionaries
@property (nonatomic, strong) NSArray *emailDictionaries;
@property (nonatomic, strong) NSArray *phoneDictionaries;
@property (nonatomic, strong) NSArray *relatedNameDictionaries;
@property (nonatomic, strong) NSArray *urlDictionaries;
@property (nonatomic, strong) NSArray *dateDictionaries;
@property (nonatomic, strong) NSArray *addressDictionaries;
@property (nonatomic, strong) NSArray *smsDictionaries;
#pragma mark IMAGES
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;
#pragma mark MAILINGLIST

@end