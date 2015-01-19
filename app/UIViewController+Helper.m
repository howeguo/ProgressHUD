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

static char LoadingViewIsShowing;

@implementation UIViewController (Helper)

#pragma mark - loadingViewIsShowing
- (void)setLoadingViewIsShowing:(BOOL)loadingViewIsShowing {
    [self willChangeValueForKey:@"loadingViewIsShowing"];
    objc_setAssociatedObject(self, &LoadingViewIsShowing,
                             [NSNumber numberWithBool:loadingViewIsShowing],
                             OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"loadingViewIsShowing"];
}

- (BOOL)loadingViewIsShowing {
    return [objc_getAssociatedObject(self, &LoadingViewIsShowing) boolValue];
}


#pragma mark - Dismiss Self
- (IBAction)dismissSelfAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.presentingViewController dismissViewControllerAnimated:animated
                                                      completion:completion];
}

- (IBAction)dismissSelfAnimated:(BOOL)flag {
    [self dismissSelfAnimated:flag completion:nil];
}
- (IBAction)dismissSelf {
    [self dismissSelfAnimated:YES];
}

- (IBAction)dismissSelfWithNoAnimated {
    [self dismissSelfAnimated:NO];
}

#pragma mark - Loading View -

#pragma mark - show
- (void)startLoading {
    [self setLoadingViewIsShowing:YES];
	[self startLoadingWithInteractionEnable:YES];
}

- (void)startLoadingWithInteractionEnable:(BOOL)interaction {
    [self setLoadingViewIsShowing:YES];
    [ProgressHUD show:nil Interaction:interaction];
}

- (void)showStatus:(NSString *)text {
    [self setLoadingViewIsShowing:YES];
    [ProgressHUD show:text];
}

- (void)startLoadingWithStatus:(NSString *)text {
    [self setLoadingViewIsShowing:YES];
    [ProgressHUD show:text];
}

#pragma mark - hide
- (void)stopLoading {
    if ([self loadingViewIsShowing]) {
        [self setLoadingViewIsShowing:NO];
        if ([ProgressHUD isShowing]) {
            [ProgressHUD dismiss];
        }
    }
}

#pragma mark - show the hide
- (void)showErrorWithStatus:(NSString *)text {
	[ProgressHUD showError:text];
}

- (void)showSuccessWithStatus:(NSString *)text {
	[ProgressHUD showSuccess:text];
}


- (void)showTip:(NSString *)tip {
    [ProgressHUD showTip:tip];
}

#pragma mark - handle error
- (void)handelEventError:(id)error {
    UIViewController *currentVC = [[self class] currentViewController];
    if (self == currentVC) {
        NSString *errmsg = nil;
        if ([error isKindOfClass:[NSDictionary class]]) {
            errmsg = [error objectForKey:@"errmsg"];
        } else if ([error isKindOfClass:[NSError class]]) {
            errmsg = [(NSError *)error localizedDescription];
        } else {
            error = @"发生未知错误";
        }
        
        errmsg ? [self showErrorWithStatus:errmsg] : nil;
    }
}


@end
