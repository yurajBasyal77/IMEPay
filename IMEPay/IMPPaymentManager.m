//
//  IMPPaymentManager.m
//  IMEPay
//
//  Created by Manoj Karki on 7/13/17.
//  Copyright © 2017 Manoj Karki. All rights reserved.
//

#import "IMPPaymentManager.h"
#import "Helper.h"
#import "SplashViewController.h"
#import "MobileNumberViewController.h"

@interface IMPPaymentManager()

@property (nonatomic, strong) NSMutableDictionary  *paymentParams;

@end

@implementation IMPPaymentManager

- (instancetype)initWithEnvironment:(APIEnvironment)environment {
    if (!self)
        self = [super init];
    SessionManager *sessionManager = [SessionManager sharedInstance];
    sessionManager.environment = environment;
    return  self;
}

- (void)payWithUsername:(NSString *)userName password:(NSString *)password  merchantCode:(NSString *)merchantCode merchantName: (NSString *)merchantName  merchantUrl:(NSString *)merchantUrl amount:(NSString *)amount referenceId: (NSString *)referenceId module: (NSString *)module success: (void(^)(IMPTransactionInfo *transactionInfo))success failure: (void(^)(IMPTransactionInfo *transactionInfo, NSString *errorMessage))failure {

    NSString *curatedRefId = [referenceId  stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *curatedMerchantName = [merchantName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSData *dataTake2 = [module dataUsingEncoding:NSUTF8StringEncoding];

    // Convert to Base64 data
    NSData *base64Data = [dataTake2 base64EncodedDataWithOptions:0];
    NSString *base64Module = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];

    _paymentParams = [NSMutableDictionary dictionaryWithDictionary: @{  @"userName": userName ? userName : @"",
                                                                        @"password": password ? password : @"",
                                                                        @"merchantCode" : merchantCode ? merchantCode : @"",
                                                                        @"merchantName" : curatedMerchantName ? curatedMerchantName : @"",
                                                                        @"merchantUrl": merchantUrl ? merchantUrl : @"",
                                                                        @"amount" : amount ? amount : @"",
                                                                        @"referenceId" : curatedRefId ? curatedRefId : @"",
                                                                        @"module" : base64Module ? base64Module : @"",
                                                                        @"mobileNumber" : @""
                                                                        }];
    SessionManager *sessionManager = [SessionManager sharedInstance];
    [sessionManager setAuthorization:userName password:password];
    [sessionManager setModule:base64Module];
    [self gotoMobileNumberVc:success failure:failure];
}

- (void)gotoMobileNumberVc: (void(^)(IMPTransactionInfo *transactionInfo))success failure: (void(^)(IMPTransactionInfo *transactionInfo, NSString *error))failure {

    NSBundle *bundle = [NSBundle bundleForClass:[IMPPaymentManager class]];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:bundle];
    MobileNumberViewController *mobileNumVc = (MobileNumberViewController *) [sb instantiateViewControllerWithIdentifier:@"MobileNumberViewController"];
    mobileNumVc.paymentParams = _paymentParams;
    mobileNumVc.success  = success;
    mobileNumVc.failure = failure;

    UINavigationController *mobileNumVcNav = baseNav(mobileNumVc);

    NSLog(@"top view controller %@", topViewController());

    NSLog(@"shared application %@", [UIApplication sharedApplication]);

    [topViewController() presentViewController:mobileNumVcNav animated:YES completion:nil];
}

@end
