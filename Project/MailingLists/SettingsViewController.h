//
//  SettingsViewController.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۳/۱۸ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SoundEffect.h"

@interface SettingsViewController : UIViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    
}

@property (strong, nonatomic) SKProductsRequest *request;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;
@property (weak,   nonatomic) IBOutlet UILabel *versionLabel;
@property (weak,   nonatomic) IBOutlet UILabel *productLabel;
@property (weak,   nonatomic) IBOutlet UITextView *productDescription;
@property (weak,   nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak,   nonatomic) IBOutlet UIButton *buyButton;
@property (weak,   nonatomic) IBOutlet UISwitch *soundFXSwitch;
@property (weak,   nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak,   nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) SoundEffect* selectionSwitchFX;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)buyProduct:(id)sender;
- (IBAction)restorePurchase:(id)sender;
- (IBAction)switchSoundFX:(id)sender;
- (IBAction)showQuickTour:(id)sender;
- (IBAction)appLinkTapped:(id)sender;

-(void)getProductID:(UIViewController *)viewController;

@end
