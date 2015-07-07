//
//  eSoftContact.h
//  Birthday
//
//  Created by Hadi Sharghi on ۹۰/۲/۳۰.
//  Copyright ۱۳۹۰ __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


// ABContact.h
@interface eSoftContact : NSObject
{
    ABRecordRef _record;
    BOOL addToUpcomingList;
}

//@property (nonatomic, readwrite) ABRecordID recID;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, readonly) ABRecordRef RecordRef;
@property (nonatomic, readonly) ABRecordID RecordID;
@property (unsafe_unretained, nonatomic, readonly) NSString *firstName;
@property (unsafe_unretained, nonatomic, readonly) NSString *lastName;
@property (unsafe_unretained, nonatomic, readonly) NSString *fullName;
@property (nonatomic, strong) NSDictionary *emails;
@property (unsafe_unretained, nonatomic, readonly) NSDictionary *phones;
@property (nonatomic, strong) NSDictionary *dates;
@property (nonatomic, strong) UIImage* pictureID;
@property (nonatomic, strong) UIImage* thumbnailImage;
@property (nonatomic, readwrite)   BOOL addToUpcomingList;

- (id)initWithRecord:(ABRecordRef)aRecord;
- (NSString *) fullName;
@end

