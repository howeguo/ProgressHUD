//
//  UIViewController+Helper.h
//  tataUFO
//
//  Created by Can on 9/17/14.
//  Copyright (c) 2014 tataUFO.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helper)


#pragma mark - show
- (void)startLoading;
- (void)startLoadingWithInteractionEnable:(BOOL)interaction;
- (void)startLoadingWithStatus:(NSString *)text;
- (void)startLoadingWithStatus:(NSString *)text interactionEnable:(BOOL)interaction;

#pragma mark - hide
- (void)stopLoading;
- (void)stopLoadingIfShowingInSelf;

#pragma mark - show then hide
- (void)showErrorWithStatus:(NSString *)text;
- (void)showSuccessWithStatus:(NSString *)text;
- (void)showTip:(NSString *)tip;

@end
