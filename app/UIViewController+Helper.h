//
//  UIViewController+Helper.h
//  tataUFO
//
//  Created by Can on 9/17/14.
//  Copyright (c) 2014 tataUFO.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helper)


- (IBAction)dismissSelf;
- (IBAction)dismissSelfWithNoAnimated;
- (IBAction)dismissSelfAnimated:(BOOL)animated completion:(void (^)(void))completion;



- (void)startLoading;
- (void)startLoadingWithInteractionEnable:(BOOL)interaction;
- (void)startLoadingWithStatus:(NSString *)text;

- (void)stopLoading;

- (void)showErrorWithStatus:(NSString *)text;
- (void)showSuccessWithStatus:(NSString *)text;
- (void)showStatus:(NSString *)text;
- (void)showTip:(NSString *)tip;

- (BOOL)loadingViewIsShowing;

//==========

- (void)handelEventError:(id)error;
@end
