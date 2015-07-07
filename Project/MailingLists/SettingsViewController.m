//
//  SettingsViewController.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۳/۱۸ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "SettingsViewController.h"
#import "MailingListViewController.h"


@interface SettingsViewController ()

@property (strong, nonatomic) MailingListViewController *homeViewController;

@end

@implementation SettingsViewController

- (void)setupViewForPremium:(BOOL)isPremium
{
//    UIColor *red = [UIColor colorWithRed:209/255.0 green:49/255.0 blue:46/255.0 alpha:1];
    UIColor *blue = [UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1];
    
    if (isPremium)
    {
        _buyButton.enabled = NO;
        [_buyButton setImage:[UIImage imageNamed:@"PurchasedButton_Disabled.png"] forState:UIControlStateDisabled];
        _purchaseButton.enabled = NO;
        _versionLabel.text = @"* Premium Version *";
        _versionLabel.textColor = blue;
        _versionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _productLabel.text = @"Thank you for purchasing Premium version";
        CGRect frame = _productLabel.frame;
        frame.size.height = 50.0;
        _productLabel.frame = frame;
        _productDescription.text = @"";
    }
    else
    {
        _loadingIndicator.hidden = NO;
        [_loadingIndicator startAnimating];
        _loadingLabel.text = @"Loading info...";
        CGRect frame = _productLabel.frame;
        frame.size.height = 21.0f;
        _productLabel.frame = frame;
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if([UIScreen mainScreen].bounds.size.height < 568)    // iPhone 3.5"
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 60);

    self.title = @"Settings";
    
    NSString *ver = [NSString stringWithFormat:@" %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];

    _appVersionLabel.text = [_appVersionLabel.text stringByAppendingString:ver];
    _priceLabel.hidden = YES;
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    _soundFXSwitch.on = kAppDelegate.playSoundFX;
    CGPoint center = _loadingIndicator.center;
    center.y = 229.0;
    _loadingIndicator.center = center;
    
    _buyButton.enabled = NO;
    _purchaseButton.enabled = NO;
    [_buyButton setImage:[UIImage imageNamed:@"PurchaseNotAvailable.png"] forState:UIControlStateDisabled];
    [self setupViewForPremium:kAppDelegate.premiumVersion];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [self.navigationController setToolbarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buyProduct:(id)sender {
    CGPoint center = _loadingIndicator.center;
    center.y = 283.0;
    _loadingIndicator.center = center;

    SKPayment *payment = [SKPayment paymentWithProduct:_product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (IBAction)restorePurchase:(id)sender {
    CGPoint center = _loadingIndicator.center;
    center.y += 54.0;
    _loadingIndicator.center = center;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)switchSoundFX:(id)sender {
    
    UISwitch *sw = (UISwitch *)sender;
    if (sw.isOn)
    {
        if (!_selectionSwitchFX)
            _selectionSwitchFX = [[SoundEffect alloc] initWithSoundNamed:@"SwitchChange.wav"];
        [_selectionSwitchFX play];
    }

    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:sw.isOn forKey:kSoundFX];
    kAppDelegate.playSoundFX = sw.isOn;
    [ud synchronize];
}

- (IBAction)showQuickTour:(id)sender {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

    kAppDelegate.showQuickTour = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [UIView animateWithDuration:1
                     animations:^{
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [_homeViewController showQuickTour:sender];
                     }];
}

- (IBAction)appLinkTapped:(id)sender {
    UIApplication *myApp = [UIApplication sharedApplication];
    NSString *supportURL = @"http://designbymax.com/app";
    [myApp openURL:[NSURL URLWithString:supportURL]];
}

-(void)getProductID:(MailingListViewController *)viewController
{
    _homeViewController = viewController;

    if (kAppDelegate.premiumVersion) return;
    
    if ([SKPaymentQueue canMakePayments])
    {
        NSLog(@"self.productID: %@", self.productID);
        self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
        self.request.delegate = self;
        [self.request start];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Purchasing" message:@"Please enable In-App Purchase in settings to be able to purchase"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [_loadingIndicator stopAnimating];
    _loadingLabel.text = @"";
    _buyButton.enabled = NO;
    _purchaseButton.enabled = NO;
    _productLabel.text = @"Can not get product info";
    _productDescription.text = @"\n\nProduct info can not be retrieved. Check internet connectivity or try again later.";
    _productDescription.textAlignment = NSTextAlignmentCenter;
}


#pragma mark _
#pragma mark StoreKit delegate methods


-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (kAppDelegate.premiumVersion) return;
    
    NSArray *products = response.products;
    if (products.count != 0)
    {
        [_loadingIndicator stopAnimating];
        _loadingLabel.text = @"";
        _product = products[0];
        _buyButton.enabled = YES;
        _purchaseButton.enabled = YES;
//        [_purchaseButton setImage:[UIImage imageNamed:@"PurchaseButtonWithPrice.png"] forState:UIControlStateNormal];
        _productLabel.text  = [NSString stringWithFormat:@"Purchase %@", _product.localizedTitle];
        _productDescription.text = _product.localizedDescription;
        _productDescription.textAlignment = NSTextAlignmentJustified;
        _productDescription.font = [UIFont systemFontOfSize:16];
        
        NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [priceFormatter setLocale:_product.priceLocale];
        NSString *price = [priceFormatter stringFromNumber:_product.price];
        _priceLabel.text = [NSString stringWithFormat:@"(%@)", price];
        _priceLabel.hidden = NO;
        
    }
    else
    {
        _productLabel.text = @"Product NOT Found";
        _productDescription.text = @"Product info can not be retrieved. Check internet connectivity or try again later.";
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"error: %@",[transactions[0] error].debugDescription);
    NSLog(@"removed %@", transactions);
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        [_loadingIndicator startAnimating];
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                [self unlockPurchase];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                
                case SKPaymentTransactionStateRestored:
            {
                [self unlockPurchase];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                
                case SKPaymentTransactionStateFailed:
            {
                NSLog(@"Transaction failed");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                CGPoint center = _loadingIndicator.center;
                center.y = 229.0;
                _loadingIndicator.center = center;
                [_loadingIndicator stopAnimating];
                _productLabel.text = @"Purchase error";
                _productDescription.text = @"Sorry, Can not purchase product at the time. Check your iTunes account or internet connectivity and try again. If the problem persists contact support.";
                _productDescription.textAlignment = NSTextAlignmentCenter;

            }
                break;
                
            default:
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self unlockPurchase];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Restore failed: %@", error.localizedDescription);
}

-(void)unlockPurchase
{
    [_loadingIndicator stopAnimating];
    [self setupViewForPremium:YES];
    [_homeViewController Purchased];
}

-(void)dealloc
{
     [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


























@end
