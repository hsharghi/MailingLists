//
//  AppDelegate.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۶ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#define kSoundFX @"SoundFX"
#define kShowEditOptionsPopUp @"ShowEditOptionsPopUp"
#define kNumberOfLaunches @"NumberOfLaunches"
#define kShowQuickTour @"ShowQuickTour"
#define kAppStoreRate @"AppStoreRate"
#define kRated @"Rated"
#define kPremium @"Premium"
#define kEnteredForground @"EnteredForeground"
#define kPremiumIntValue 74442229

#define kAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)


//#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL isFirstLaunch;
}

@property (strong, nonatomic) UIWindow *window;
@property (assign) BOOL showEditOptionsPopUp;
@property (assign) BOOL showRateAlert;
@property (assign) BOOL showQuickTour;
@property (assign) BOOL premiumVersion;
@property (assign) BOOL playSoundFX;

//@property (strong, nonatomic) SKProductsRequest *request;
//@property (strong, nonatomic) SKProduct *product;
//@property (strong, nonatomic) NSString *productID;

@end
