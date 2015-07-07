/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])


#import "ABContact.h"
#import "ABContactsHelper.h"
@implementation ABContact
@synthesize record;
// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init]) record = CFRetain(aRecord);
    return self;
}
+ (id) contactWithRecord: (ABRecordRef) person
{
    return [[[ABContact alloc] initWithRecord:person] autorelease];
}
+ (id) contactWithRecordID: (ABRecordID) recordID
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef contactrec = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    CFRelease(addressBook);
    ABContact *contact = [self contactWithRecord:contactrec];
    return contact;
}
// Thanks to Ciaran
+ (id) contact
{
    ABRecordRef person = ABPersonCreate();
    id contact = [ABContact contactWithRecord:person];
    CFRelease(person);
    
    return contact;
}
//+ (id) addContactWithName:(NSString *)name
//{
//    ABRecordRef record  = ABPersonCreate();
//    
//    id contact = [ABContact contactWithRecord:record];
//    
//    contact.organization = mailingListIdentifier;
//    
//    return contact;
//}

- (void) dealloc
{
    if (record) CFRelease(record);
    [super dealloc];
}
#pragma mark utilities
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty
{
    return (NSString *)CFBridgingRelease(ABPersonCopyLocalizedPropertyName(aProperty));
}
+ (ABPropertyType) propertyType: (ABPropertyID) aProperty
{
    return ABPersonGetTypeOfProperty(aProperty);
}
// Thanks to Eridius for suggestions re switch
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty
{
    switch (ABPersonGetTypeOfProperty(aProperty))
    {
        case kABInvalidPropertyType: return @"Invalid Property";
        case kABStringPropertyType: return @"String";
        case kABIntegerPropertyType: return @"Integer";
        case kABRealPropertyType: return @"Float";
        case kABDateTimePropertyType: return @"Date";
        case kABDictionaryPropertyType: return @"Dictionary";
        case kABMultiStringPropertyType: return @"Multi String";
        case kABMultiIntegerPropertyType: return @"Multi Integer";
        case kABMultiRealPropertyType: return @"Multi Float";
        case kABMultiDateTimePropertyType: return @"Multi Date";
        case kABMultiDictionaryPropertyType: return @"Multi Dictionary";
        default: return @"Invalid Property";
    }
}
+ (NSString *) propertyString: (ABPropertyID) aProperty
{
    /* switch (aProperty) // Sorry, this won't compile
     {
     case kABPersonFirstNameProperty: return @"First Name";
     case kABPersonLastNameProperty: return @"Last Name";
     case kABPersonMiddleNameProperty: return @"Middle Name";
     case kABPersonPrefixProperty: return @"Prefix";
     case kABPersonSuffixProperty: return @"Suffix";
     case kABPersonNicknameProperty: return @"Nickname";
     case kABPersonFirstNamePhoneticProperty: return @"Phonetic First Name";
     case kABPersonLastNamePhoneticProperty: return @"Phonetic Last Name";
     case kABPersonMiddleNamePhoneticProperty: return @"Phonetic Middle Name";
     case kABPersonOrganizationProperty: return @"Organization";
     case kABPersonJobTitleProperty: return @"Job Title";
     case kABPersonDepartmentProperty: return @"Department";
     case kABPersonEmailProperty: return @"Email";
     case kABPersonBirthdayProperty: return @"Birthday";
     case kABPersonNoteProperty: return @"Note";
     case kABPersonCreationDateProperty: return @"Creation Date";
     case kABPersonModificationDateProperty: return @"Modification Date";
     case kABPersonAddressProperty: return @"Address";
     case kABPersonDateProperty: return @"Date";
     case kABPersonKindProperty: return @"Kind";
     case kABPersonPhoneProperty: return @"Phone";
     case kABPersonInstantMessageProperty: return @"Instant Message";
     case kABPersonURLProperty: return @"URL";
     case kABPersonRelatedNamesProperty: return @"Related Name";                     
     } */
    
    if (aProperty == kABPersonFirstNameProperty) return @"First Name";
    if (aProperty == kABPersonLastNameProperty) return @"Last Name";
    if (aProperty == kABPersonMiddleNameProperty) return @"Middle Name";
    if (aProperty == kABPersonPrefixProperty) return @"Prefix";
    if (aProperty == kABPersonSuffixProperty) return @"Suffix";
    if (aProperty == kABPersonNicknameProperty) return @"Nickname";
    if (aProperty == kABPersonFirstNamePhoneticProperty) return @"Phonetic First Name";
    if (aProperty == kABPersonLastNamePhoneticProperty) return @"Phonetic Last Name";
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return @"Phonetic Middle Name";
    if (aProperty == kABPersonOrganizationProperty) return @"Organization";
    if (aProperty == kABPersonJobTitleProperty) return @"Job Title";
    if (aProperty == kABPersonDepartmentProperty) return @"Department";
    if (aProperty == kABPersonEmailProperty) return @"Email";
    if (aProperty == kABPersonBirthdayProperty) return @"Birthday";
    if (aProperty == kABPersonNoteProperty) return @"Note";
    if (aProperty == kABPersonCreationDateProperty) return @"Creation Date";
    if (aProperty == kABPersonModificationDateProperty) return @"Modification Date";
    if (aProperty == kABPersonAddressProperty) return @"Address";
    if (aProperty == kABPersonDateProperty) return @"Date";
    if (aProperty == kABPersonKindProperty) return @"Kind";
    if (aProperty == kABPersonPhoneProperty) return @"Phone";
    if (aProperty == kABPersonInstantMessageProperty) return @"Instant Message";
    if (aProperty == kABPersonURLProperty) return @"URL";
    if (aProperty == kABPersonRelatedNamesProperty) return @"Related Name";
    return nil;
}
+ (BOOL) propertyIsMultivalue: (ABPropertyID) aProperty;
{
    if (aProperty == kABPersonFirstNameProperty) return NO;
    if (aProperty == kABPersonLastNameProperty) return NO;
    if (aProperty == kABPersonMiddleNameProperty) return NO;
    if (aProperty == kABPersonPrefixProperty) return NO;
    if (aProperty == kABPersonSuffixProperty) return NO;
    if (aProperty == kABPersonNicknameProperty) return NO;
    if (aProperty == kABPersonFirstNamePhoneticProperty) return NO;
    if (aProperty == kABPersonLastNamePhoneticProperty) return NO;
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return NO;
    if (aProperty == kABPersonOrganizationProperty) return NO;
    if (aProperty == kABPersonJobTitleProperty) return NO;
    if (aProperty == kABPersonDepartmentProperty) return NO;
    if (aProperty == kABPersonBirthdayProperty) return NO;
    if (aProperty == kABPersonNoteProperty) return NO;
    if (aProperty == kABPersonCreationDateProperty) return NO;
    if (aProperty == kABPersonModificationDateProperty) return NO;
    
    return YES;
    /*
     if (aProperty == kABPersonEmailProperty) return YES;
     if (aProperty == kABPersonAddressProperty) return YES;
     if (aProperty == kABPersonDateProperty) return YES;
     if (aProperty == kABPersonPhoneProperty) return YES;
     if (aProperty == kABPersonInstantMessageProperty) return YES;
     if (aProperty == kABPersonURLProperty) return YES;
     if (aProperty == kABPersonRelatedNamesProperty) return YES;
     */
}
+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    // Recover the property for a given record
    CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    NSArray *items = (NSArray *)CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(theProperty));
    CFRelease(theProperty);
    return items;
}
+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    return (id) CFBridgingRelease(ABRecordCopyValue(record, anID));
}
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (value) [dict setObject:value forKey:@"value"];
    if (label) [dict setObject:(NSString *)CFBridgingRelease(label) forKey:@"label"];
    return dict;
}
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
                           withState:(NSString *) state withZip: (NSString *) zip
                         withCountry: (NSString *) country withCode: (NSString *) code
{
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if (street) [md setObject:street forKey:(NSString *) kABPersonAddressStreetKey];
    if (city) [md setObject:city forKey:(NSString *) kABPersonAddressCityKey];
    if (state) [md setObject:state forKey:(NSString *) kABPersonAddressStateKey];
    if (zip) [md setObject:zip forKey:(NSString *) kABPersonAddressZIPKey];
    if (country) [md setObject:country forKey:(NSString *) kABPersonAddressCountryKey];
    if (code) [md setObject:code forKey:(NSString *) kABPersonAddressCountryCodeKey];
    return md;
}
+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName
{
    NSMutableDictionary *sms = [NSMutableDictionary dictionary];
    if (service) [sms setObject:(NSString *) CFBridgingRelease(service) forKey:(NSString *) kABPersonInstantMessageServiceKey];
    if (userName) [sms setObject:userName forKey:(NSString *) kABPersonInstantMessageUsernameKey];
    return sms;
}
// Thanks to Eridius for suggestions re: error
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
#pragma mark Getting Single Value Strings
- (NSString *) getRecordString:(ABPropertyID) anID
{
    return (NSString *) CFBridgingRelease(ABRecordCopyValue(record, anID));
}
- (NSString *) firstname {
    NSString *name = [self getRecordString:kABPersonFirstNameProperty];
    if (!name) name = @"";
    return name;
//    return (([self getRecordString:kABPersonFirstNameProperty] == nil) ? @"" : [self getRecordString:kABPersonFirstNameProperty]);
}
- (NSString *) lastname {
    NSString *name = [self getRecordString:kABPersonLastNameProperty];
    if (!name) name = @"";
    return name;
//    return (([self getRecordString:kABPersonLastNameProperty] == nil) ? @"" : [self getRecordString:kABPersonLastNameProperty]);
}
- (NSString *) middlename {
    NSString *name = [self getRecordString:kABPersonMiddleNameProperty];
    if (!name) name = @"";
    return name;
//    return (([self getRecordString:kABPersonMiddleNameProperty] == nil) ? @"" : [self getRecordString:kABPersonMiddleNameProperty]);
}
- (NSString *) organization {
    NSString *name = [self getRecordString:kABPersonOrganizationProperty];
    if (!name) name = @"";
    return name;
//    return (([self getRecordString:kABPersonOrganizationProperty] == nil) ? @"" : [self getRecordString:kABPersonOrganizationProperty]);
}

- (NSString *) prefix {return [self getRecordString:kABPersonPrefixProperty];}
- (NSString *) suffix {return [self getRecordString:kABPersonSuffixProperty];}
- (NSString *) nickname {return [self getRecordString:kABPersonNicknameProperty];}
- (NSString *) firstnamephonetic {return [self getRecordString:kABPersonFirstNamePhoneticProperty];}
- (NSString *) lastnamephonetic {return [self getRecordString:kABPersonLastNamePhoneticProperty];}
- (NSString *) middlenamephonetic {return [self getRecordString:kABPersonMiddleNamePhoneticProperty];}
- (NSString *) jobtitle {return [self getRecordString:kABPersonJobTitleProperty];}
- (NSString *) department {return [self getRecordString:kABPersonDepartmentProperty];}
- (NSString *) note {return [self getRecordString:kABPersonNoteProperty];}
#pragma mark Contact Name Utility
- (NSString *) fullName
{
    NSMutableString *string = [NSMutableString string];
    
    if (self.firstname || self.lastname)
    {
        if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
        if (self.lastname) [string appendFormat:@"%@", self.lastname];
    }
    
    NSString *full = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (([full isEqualToString:@""]) && (self.organization))
        full = self.organization;
    
    return full;
}
- (NSString *) contactName
{
    NSMutableString *string = [NSMutableString string];
    
    if (self.firstname || self.lastname)
    {
        if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
        if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
        if (self.middlename) [string appendFormat:@"%@ ", self.middlename];
        if (self.lastname) [string appendFormat:@"%@", self.lastname];
        
        if (self.suffix && string.length)
            [string appendFormat:@", %@ ", self.suffix];
        else
            [string appendFormat:@" "];
    }
    NSString *completeName = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ((self.organization) && ([completeName isEqualToString:@""]))
        completeName = self.organization;
    
    return completeName;
}
- (NSString *) compositeName
{
    NSString *string = (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(record));
    return string;
}
- (NSString *) mailingListName
{
//    NSString *fname = self.firstname;
//    NSString *lname = self.lastname;
//    NSString *organ = self.organization;
    
    if ((![self.firstname isEqualToString:mailingListIdentifier]) && (self.firstname))
            return self.firstname;
    else if ((![self.lastname isEqualToString:mailingListIdentifier]) && (self.lastname))
            return self.lastname;

    return self.organization;
}

#pragma mark Dates
- (NSDate *) getRecordDate:(ABPropertyID) anID
{
    return (NSDate *) CFBridgingRelease(ABRecordCopyValue(record, anID));
}
- (NSDate *) birthday {return [self getRecordDate:kABPersonBirthdayProperty];}
- (NSDate *) creationDate {return [self getRecordDate:kABPersonCreationDateProperty];}
- (NSDate *) modificationDate {return [self getRecordDate:kABPersonModificationDateProperty];}
#pragma mark Getting MultiValue Elements
- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, ABRecordGetRecordID(record));
    
    CFTypeRef theProperty = ABRecordCopyValue(person, anID);
    NSArray *items = (NSArray *)CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(theProperty));
  
    CFRelease(theProperty);
    CFRelease(ab);

    return items;
}
- (NSArray *) labelsForProperty: (ABPropertyID) anID
{
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, ABRecordGetRecordID(record));
    
    CFTypeRef theProperty = ABRecordCopyValue(person, anID);
//
//    CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
    {
        NSString *label = (NSString *)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(theProperty, i));
        if ([label rangeOfString:@">!$_"].location != NSNotFound)
            label = [[label substringFromIndex:4] substringToIndex:[label rangeOfString:@">!$_"].location-4];
        
        [labels addObject:label];
    }
    CFRelease(theProperty);
    CFRelease(ab);

    return labels;
}
- (NSArray *) emailArray {return [self arrayForProperty:kABPersonEmailProperty];}
- (NSArray *) emailLabels {return [self labelsForProperty:kABPersonEmailProperty];}
- (NSArray *) phoneArray {return [self arrayForProperty:kABPersonPhoneProperty];}
- (NSArray *) phoneLabels {return [self labelsForProperty:kABPersonPhoneProperty];}
- (NSArray *) relatedNameArray {return [self arrayForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) relatedNameLabels {return [self labelsForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) urlArray {return [self arrayForProperty:kABPersonURLProperty];}
- (NSArray *) urlLabels {return [self labelsForProperty:kABPersonURLProperty];}
- (NSArray *) dateArray {return [self arrayForProperty:kABPersonDateProperty];}
- (NSArray *) dateLabels {return [self labelsForProperty:kABPersonDateProperty];}
- (NSArray *) addressArray {return [self arrayForProperty:kABPersonAddressProperty];}
- (NSArray *) addressLabels {return [self labelsForProperty:kABPersonAddressProperty];}
- (NSArray *) smsArray {return [self arrayForProperty:kABPersonInstantMessageProperty];}
- (NSArray *) smsLabels {return [self labelsForProperty:kABPersonInstantMessageProperty];}
- (NSString *) phonenumbers {return [self.phoneArray componentsJoinedByString:@" "];}
- (NSString *) emailaddresses {return [self.emailArray componentsJoinedByString:@" "];}
- (NSString *) urls {return [self.urlArray componentsJoinedByString:@" "];}
- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
    NSArray *valueArray = [self arrayForProperty:aProperty];
    NSArray *labelArray = [self labelsForProperty:aProperty];
    
    NSUInteger num = MIN(valueArray.count, labelArray.count);
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < num; i++)
    {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        [md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
        [md setObject:[labelArray objectAtIndex:i] forKey:@"label"];
        [items addObject:md];
    }
    return items;
}
- (NSArray *) emailDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonEmailProperty];
}
- (NSArray *) phoneDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonPhoneProperty];
}
- (NSArray *) relatedNameDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
}
- (NSArray *) urlDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonURLProperty];
}
- (NSArray *) dateDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonDateProperty];
}
- (NSArray *) addressDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonAddressProperty];
}
- (NSArray *) smsDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
}
#pragma mark Setting Strings
- (BOOL) setString: (NSString *) aString forProperty:(ABPropertyID) anID
{
    CFErrorRef error;
    BOOL success = ABRecordSetValue(record, anID, (__bridge CFStringRef) aString, &error);
    if (!success) NSLog(@"Error: %@", [(NSError *)CFBridgingRelease(error) localizedDescription]);
    return success;
}
- (void) setFirstname: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNameProperty];}
- (void) setLastname: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNameProperty];}
- (void) setMiddlename: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNameProperty];}
- (void) setPrefix: (NSString *) aString {[self setString: aString forProperty: kABPersonPrefixProperty];}
- (void) setSuffix: (NSString *) aString {[self setString: aString forProperty: kABPersonSuffixProperty];}
- (void) setNickname: (NSString *) aString {[self setString: aString forProperty: kABPersonNicknameProperty];}
- (void) setFirstnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNamePhoneticProperty];}
- (void) setLastnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNamePhoneticProperty];}
- (void) setMiddlenamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNamePhoneticProperty];}
- (void) setOrganization: (NSString *) aString {[self setString: aString forProperty: kABPersonOrganizationProperty];}
- (void) setJobtitle: (NSString *) aString {[self setString: aString forProperty: kABPersonJobTitleProperty];}
- (void) setDepartment: (NSString *) aString {[self setString: aString forProperty: kABPersonDepartmentProperty];}
- (void) setNote: (NSString *) aString {[self setString: aString forProperty: kABPersonNoteProperty];}
- (void) setMailingListName: (NSString *) aString
{
    if ((self.organization.length > 0) && ([self.organization isEqualToString:mailingListIdentifier]))
    {
        (self.firstname.length > 0 ?
         [self setString: aString forProperty:kABPersonFirstNameProperty] :
         [self setString: aString forProperty:kABPersonLastNameProperty]);
    }
    else if ((self.firstname.length > 0) && (![self.firstname isEqualToString:mailingListIdentifier]))
        [self setString: aString forProperty:kABPersonFirstNameProperty];
    else
        [self setString: aString forProperty:kABPersonLastNameProperty];
}

#pragma mark Setting Dates
- (BOOL) setDate: (NSDate *) aDate forProperty:(ABPropertyID) anID
{
    CFErrorRef error;
    BOOL success = ABRecordSetValue(record, anID, (CFDateRef) CFBridgingRetain(aDate), &error);
    CFRelease(aDate);
    if (!success) NSLog(@"Error: %@", [(NSError *)CFBridgingRelease(error) localizedDescription]);
    return success;
}
- (void) setBirthday: (NSDate *) aDate {[self setDate: aDate forProperty: kABPersonBirthdayProperty];}
#pragma mark Setting MultiValue
- (BOOL) setMulti: (ABMutableMultiValueRef) multi forProperty: (ABPropertyID) anID
{
    CFErrorRef error;
    BOOL success = ABRecordSetValue(record, anID, multi, &error);
    if (!success) NSLog(@"Error: %@", [(NSError *)CFBridgingRelease(error) localizedDescription]);
    return success;
}
- (ABMutableMultiValueRef) createMultiValueFromArray: (NSArray *) anArray withType: (ABPropertyType) aType
{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(aType);
    for (NSDictionary *dict in anArray)
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
    
    CFAutorelease(multi);
    return multi;
}
- (void) setEmailDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMulti:multi forProperty:kABPersonEmailProperty];
    
//    CFRelease(multi);
}
- (void) setPhoneDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
    // kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMulti:multi forProperty:kABPersonPhoneProperty];
//    CFRelease(multi);
}
- (void) setUrlDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonHomePageLabel
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMulti:multi forProperty:kABPersonURLProperty];
//    CFRelease(multi);
}
// Not used/shown on iPhone
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonMotherLabel, kABPersonFatherLabel, kABPersonParentLabel,
    // kABPersonSisterLabel, kABPersonBrotherLabel, kABPersonChildLabel,
    // kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel,
    // kABPersonManagerLabel, kABPersonAssistantLabel
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMulti:multi forProperty:kABPersonRelatedNamesProperty];
}
- (void) setDateDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonAnniversaryLabel
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiDateTimePropertyType];
    [self setMulti:multi forProperty:kABPersonDateProperty];
//    CFRelease(multi);
}
- (void) setAddressDictionaries: (NSArray *) dictionaries
{
    // kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
    // kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMulti:multi forProperty:kABPersonAddressProperty];
//    CFRelease(multi);
}
- (void) setSmsDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel,
    // kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
    // kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
    // kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
    // kABPersonInstantMessageServiceAIM,
    ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMulti:multi forProperty:kABPersonInstantMessageProperty];
//    CFRelease(multi);
}
#pragma mark Images
- (UIImage *) thumbnail
{
    UIImage *img = nil;
    
    // can't get image from a ABRecordRef copy
    ABRecordID contactID = ABRecordGetRecordID(record);
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABRecordRef origContactRef = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
    
    if (ABPersonHasImageData(origContactRef)) {
        NSData *imgData = (NSData*)ABPersonCopyImageDataWithFormat(origContactRef, kABPersonImageFormatThumbnail);
        img = [UIImage imageWithData: imgData];
        [imgData release];
    }
    CFRelease(addressBook);
    
    return img;
}

- (UIImage *) image
{
    if (!ABPersonHasImageData(record)) return nil;
    CFDataRef imageData = ABPersonCopyImageData(record);
    UIImage *image = [UIImage imageWithData:(__bridge NSData*)imageData];
    CFRelease(imageData);
    return image;
}
- (void) setImage: (UIImage *) image
{
    CFErrorRef error;
    BOOL success;
    
    if (image == nil) // remove
    {
        if (!ABPersonHasImageData(record)) return; // no image to remove
        success = ABPersonRemoveImageData(record, &error);
        if (!success) NSLog(@"Error: %@", [(NSError *)CFBridgingRelease(error) localizedDescription]);
        return;
    }
    
    NSData *data = UIImagePNGRepresentation(image);
    success = ABPersonSetImageData(record, (__bridge CFDataRef)data, &error);

    if (!success) NSLog(@"Error: %@", [(NSError *)CFBridgingRelease(error) localizedDescription]);
}

#pragma mark MailingList
- (NSInteger) numberOfContactsInEmailField
{
//    return 10;
    if (self.emailaddresses.length == 0)
        return 0;
    
    NSArray* allElements = [[NSArray alloc] initWithArray:[self.emailaddresses componentsSeparatedByString:@">, \""]];
    long count = allElements.count;
    [allElements release];
    
    return count;
}

@end





