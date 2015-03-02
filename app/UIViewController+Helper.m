//
//  UIViewController+Helper.m
//  tataUFO
//
//  Created by Can on 9/17/14.
//  Copyright (c) 2014 tataUFO.com. All rights reserved.
//

#import "UIViewController+Helper.h"

#import "UIViewController+Utils.h"

#import "ProgressHUD.h"

#import <objc/runtime.h>

static char CurrentShowingViewController;

@implementation UIViewController (Helper)

#pragma mark - CurrentShowingViewController
- (void)setCurrentShowingViewController:(UIViewController *)vc
{
    [self willChangeValueForKey:@"currentShowingViewController"];
    objc_setAssociatedObject(self, &CurrentShowingViewController,
                             vc,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"currentShowingViewController"];
}

- (UIViewController *)currentShowingViewController
{
    return objc_getAssociatedObject(self, &CurrentShowingViewController);
}

#pragma mark - Loading View -

#pragma mark - show
- (void)startLoading
{
    [self setCurrentShowingViewController:self];
    [self startLoadingWithInteractionEnable:YES];
}

- (void)startLoadingWithInteractionEnable:(BOOL)interaction
{
    [self setCurrentShowingViewController:self];
    [ProgressHUD show:nil Interaction:interaction];
}

- (void)showStatus:(NSString *)text
{
    [self setCurrentShowingViewController:self];
    [ProgressHUD show:text];
}

- (void)startLoadingWithStatus:(NSString *)text
{
    [self setCurrentShowingViewController:self];
    [ProgressHUD show:text];
}

- (void)startLoadingWithStatus:(NSString *)text interactionEnable:(BOOL)interaction
{
    [self setCurrentShowingViewController:self];
    [ProgressHUD show:text Interaction:interaction];
}

#pragma mark - hide

- (void)hide
{
    [self setCurrentShowingViewController:nil];
    if ([ProgressHUD isShowing]) {
        [ProgressHUD dismiss];
    }
}
- (void)stopLoading
{
    if ([self currentShowingViewController]) {
        [self hide];
    }
}

- (void)stopLoadingIfShowingInSelf
{
    if ([self currentShowingViewController] == self) {
        [self hide];
    }
}

#pragma mark - show then hide
- (void)showErrorWithStatus:(NSString *)text
{
    [ProgressHUD showError:text];
}

- (void)showSuccessWithStatus:(NSString *)text
{
    [ProgressHUD showSuccess:text];
}

- (void)showTip:(NSString *)tip
{
    [ProgressHUD showTip:tip];
}


@end
