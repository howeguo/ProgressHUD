//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"

@implementation ProgressHUD

@synthesize interaction, window, background, hud, spinner, image, label,gifView,gifLoading,animationImages;

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (ProgressHUD *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    static dispatch_once_t once = 0;
    static ProgressHUD *progressHUD;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    dispatch_once(&once, ^{ progressHUD = [[ProgressHUD alloc] init]; });
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return progressHUD;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)dismiss
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [[self shared] hudHide];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)isShowing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return ([[ProgressHUD shared] alpha] == 1);
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)show:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = YES;
    [[self shared] hudMake:status imgage:nil spin:YES hide:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)show:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status imgage:nil spin:YES hide:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showSuccess:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = YES;
    [[self shared] hudMake:status imgage:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showSuccess:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status imgage:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showError:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = YES;
    [[self shared] hudMake:status imgage:HUD_IMAGE_ERROR spin:NO hide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showError:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status imgage:HUD_IMAGE_ERROR spin:NO hide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showTip:(NSString *)tip {
    [self showTip:tip Interaction:YES];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showTip:(NSString *)tip Interaction:(BOOL)Interaction {
    if (!tip || [tip length] == 0) {
        return;
    }
    [self shared].interaction = Interaction;
    [[self shared] hudMake:tip imgage:nil spin:NO hide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([delegate respondsToSelector:@selector(window)])
        window = [delegate performSelector:@selector(window)];
    else window = [[UIApplication sharedApplication] keyWindow];
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    background = nil; hud = nil; spinner = nil; image = nil; label = nil,gifView = nil;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.alpha = 0;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudMake:(NSString *)status imgage:(UIImage *)img spin:(BOOL)spin hide:(BOOL)hide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self hudCreate];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    label.text = status;
    label.hidden = (status == nil) ? YES : NO;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    image.image = img;
    image.hidden = (img == nil) ? YES : NO;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (spin) gifLoading ? [gifView startAnimating] : [spinner startAnimating]; else gifLoading ? [gifView stopAnimating] :[spinner stopAnimating];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self hudOrient];
    [self hudSize];
    [self hudShow];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (hide) [NSThread detachNewThreadSelector:@selector(timedHide) toTarget:self withObject:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudCreate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (hud == nil)
    {
        hud = [[UIToolbar alloc] initWithFrame:CGRectZero];
        hud.barStyle = UIBarStyleBlack;
        hud.translucent = YES;
        hud.tintColor = [UIColor clearColor];
        hud.backgroundColor = HUD_BACKGROUND_COLOR;
        hud.layer.cornerRadius = 10;
        hud.layer.masksToBounds = YES;
        //-----------------------------------------------------------------------------------------------------------------------------------------
        [self registerNotifications];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (hud.superview == nil)
    {
        if (interaction == NO)
        {
            CGRect frame = CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
            background = [[UIView alloc] initWithFrame:frame];
            background.backgroundColor = [UIColor clearColor];
            [window addSubview:background];
            [background addSubview:hud];
        }
        else [window addSubview:hud];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    
    if (!gifLoading) {
        if (spinner == nil)
        {
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            spinner.color = HUD_SPINNER_COLOR;
            spinner.hidesWhenStopped = YES;
        }
        
        if (spinner.superview == nil) [hud addSubview:spinner];
    }else{
        if (gifView == nil)
        {
            gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 60.0)];
            gifView.animationDuration = 2.0;
            gifView.animationRepeatCount = 0;
            
            if (!animationImages) {
                animationImages = [NSMutableArray array];
                for (int i = 1; i < 110; i++) {
                    NSString *imgName = [NSString stringWithFormat:@"ball_%d",i];
                    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"ProgressHUD.bundle"];
                    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                    NSString *img_path = [bundle pathForResource:imgName ofType:@"png"];
                    UIImage *ballImage = [UIImage imageWithContentsOfFile:img_path];
                    if (ballImage) {
                        [animationImages addObject:ballImage];
                    }
                }
            }
            gifView.animationImages = animationImages;
            
        }
        if (gifView.superview == nil) [hud addSubview:gifView];
    }
    
    spinner.hidden = gifLoading;
    gifView.hidden = !gifLoading;
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (image == nil)
    {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    }
    if (image.superview == nil) [hud addSubview:image];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (label == nil)
    {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = HUD_STATUS_FONT;
        label.textColor = HUD_STATUS_COLOR;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 0;
    }
    if (label.superview == nil) [hud addSubview:label];
    //---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)registerNotifications
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidShowNotification object:nil];
    
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudDestroy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [label removeFromSuperview];		label = nil;
    [image removeFromSuperview];		image = nil;
    [spinner removeFromSuperview];		spinner = nil;
    [gifView removeFromSuperview];		gifView = nil;
    [hud removeFromSuperview];			hud = nil;
    [background removeFromSuperview];	background = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)rotate:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self hudOrient];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudOrient
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CGFloat rotate = 0.0;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
    if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
    if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
    if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    hud.transform = CGAffineTransformMakeRotation(rotate);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudSize
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    BOOL hasImg = (image.image != nil);
    BOOL hasSpin = gifLoading ? gifView.isAnimating : spinner.isAnimating;
    
    CGRect labelRect = CGRectZero;
    CGFloat hudWidth = 100, hudHeight = (hasImg || hasSpin ? 100 : 100 - 28);
    
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (label.text != nil)
    {
        NSDictionary *attributes = @{NSFontAttributeName:label.font};
        NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        labelRect = [label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
        
        labelRect.origin.x = 12;
        labelRect.origin.y = (hasImg || hasSpin ? 66 : 66 - 24 - 28);
        
        
        hudWidth = labelRect.size.width + 24;
        hudHeight = labelRect.size.height + (hasImg || hasSpin ? 80 : 80 - 24 - 28);
        
        if (hudWidth < 100)
        {
            hudWidth = 100;
            labelRect.origin.x = 0;
            labelRect.size.width = 100;
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CGSize screen = [UIScreen mainScreen].bounds.size;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    hud.center = CGPointMake(screen.width/2, screen.height/2);
    hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (hasImg || hasSpin) {
        CGFloat imagex = hudWidth/2;
        CGFloat imagey = (label.text == nil) ? hudHeight/2 : 36;
        image.center = spinner.center = gifView.center =  CGPointMake(imagex, imagey);
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    label.frame = labelRect;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudShow
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (self.alpha == 0)
    {
        self.alpha = 1;
        
        hud.alpha = 0;
        hud.transform = CGAffineTransformScale(hud.transform, 1.4, 1.4);
        
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
        
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            hud.transform = CGAffineTransformScale(hud.transform, 1/1.4, 1/1.4);
            hud.alpha = 1;
        }
                         completion:^(BOOL finished){ }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudHide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (self.alpha == 1)
    {
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
        
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            hud.transform = CGAffineTransformScale(hud.transform, 0.7, 0.7);
            hud.alpha = 0;
        }
                         completion:^(BOOL finished)
         {
             [self hudDestroy];
             self.alpha = 0;
         }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)timedHide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    @autoreleasepool
    {
        double length = label.text.length;
        NSTimeInterval sleep = length * 0.04 + 0.5;
        
        [NSThread sleepForTimeInterval:sleep];
        //回到主线程更新UI 2015-10-26 Howe Kuo修改
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hudHide];
        });    }
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudPosition:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CGFloat heightKeyboard = 0;
    NSTimeInterval duration = 0;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (notification != nil)
    {
        NSDictionary *info = [notification userInfo];
        CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if ((notification.name == UIKeyboardWillShowNotification) || (notification.name == UIKeyboardDidShowNotification))
        {
            heightKeyboard = keyboard.size.height;
        }
    }
    else heightKeyboard = [self keyboardHeight];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CGRect screen = [UIScreen mainScreen].bounds;
    CGPoint center = CGPointMake(screen.size.width/2, (screen.size.height-heightKeyboard)/2);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        hud.center = CGPointMake(center.x, center.y);
    } completion:nil];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (background != nil) background.frame = window.frame;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)keyboardHeight
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows])
    {
        if ([[testWindow class] isEqual:[UIWindow class]] == NO)
        {
            for (UIView *possibleKeyboard in [testWindow subviews])
            {
                if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"])
                {
                    return possibleKeyboard.bounds.size.height;
                }
                else if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"])
                {
                    for (UIView *hostKeyboard in [possibleKeyboard subviews])
                    {
                        if ([[hostKeyboard description] hasPrefix:@"<UIInputSetHost"])
                        {
                            return hostKeyboard.frame.size.height;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

@end
