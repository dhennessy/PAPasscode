//
//  PAPasscodeViewController.m
//  PAPasscode
//
//  Created by Denis Hennessy on 15/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PAPasscodeViewController.h"

#define PROMPT_HEIGHT   74
#define DIGIT_SPACING   10
#define DIGIT_WIDTH     61
#define DIGIT_HEIGHT    53
#define MARKER_WIDTH    16
#define MARKER_HEIGHT   16
#define MARKER_X        22
#define MARKER_Y        18
#define MESSAGE_HEIGHT  74
#define FAILED_LCAP     19
#define FAILED_RCAP     19
#define FAILED_HEIGHT   26
#define FAILED_MARGIN   10
#define SLIDE_DURATION  0.3

@interface PAPasscodeViewController ()
- (void)cancel:(id)sender;
- (void)handleFailedAttempt;
- (void)passcodeChanged:(id)sender;
- (void)resetFailedAttempts;
- (void)showFailedAttempts;
- (void)showScreenForPhase:(NSInteger)phase animated:(BOOL)animated;
@end

@implementation PAPasscodeViewController

- (id)initForAction:(PasscodeAction)action {
    self = [super init];
    if (self) {
        _action = action;
        switch (action) {
            case PasscodeActionSet:
                self.title = NSLocalizedString(@"Set Passcode", nil);
                _enterPrompt = NSLocalizedString(@"Enter a passcode", nil);
                _confirmPrompt = NSLocalizedString(@"Re-enter your passcode", nil);
                break;
                
            case PasscodeActionEnter:
                self.title = NSLocalizedString(@"Enter Passcode", nil);
                _enterPrompt = NSLocalizedString(@"Enter your passcode", nil);
                break;
                
            case PasscodeActionChange:
                self.title = NSLocalizedString(@"Change Passcode", nil);
                _changePrompt = NSLocalizedString(@"Enter your old passcode", nil);
                _enterPrompt = NSLocalizedString(@"Enter your new passcode", nil);
                _confirmPrompt = NSLocalizedString(@"Re-enter your new passcode", nil);
                break;
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    passcodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    passcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [passcodeTextField addTarget:self action:@selector(passcodeChanged:) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:passcodeTextField];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"papasscode_background"];
    UIImage *markerImage = [UIImage imageNamed:@"papasscode_marker"];
    CGFloat xLeft = (view.bounds.size.width - (DIGIT_WIDTH*4 + DIGIT_SPACING*3)) / 2;
    for (int i=0;i<4;i++) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = CGRectOffset(backgroundImageView.frame, xLeft, PROMPT_HEIGHT);
        [view addSubview:backgroundImageView];
        digitImageViews[i] = [[UIImageView alloc] initWithImage:markerImage];
        digitImageViews[i].frame = CGRectOffset(digitImageViews[i].frame, backgroundImageView.frame.origin.x+MARKER_X, backgroundImageView.frame.origin.y+MARKER_Y);
        [view addSubview:digitImageViews[i]];
        xLeft += DIGIT_SPACING + backgroundImage.size.width;
    }
    
    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, PROMPT_HEIGHT)];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textColor = [UIColor colorWithRed:0.30 green:0.34 blue:0.42 alpha:1.0];
    promptLabel.font = [UIFont boldSystemFontOfSize:17];
    promptLabel.shadowColor = [UIColor whiteColor];
    promptLabel.shadowOffset = CGSizeMake(0, 1);
    promptLabel.textAlignment = UITextAlignmentCenter;
    promptLabel.numberOfLines = 0;
    [view addSubview:promptLabel];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PROMPT_HEIGHT+DIGIT_HEIGHT, view.bounds.size.width, MESSAGE_HEIGHT)];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor colorWithRed:0.30 green:0.34 blue:0.42 alpha:1.0];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.shadowColor = [UIColor whiteColor];
    messageLabel.shadowOffset = CGSizeMake(0, 1);
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.numberOfLines = 0;
	messageLabel.text = _message;
    [view addSubview:messageLabel];
        
    UIImage *failedBg = [[UIImage imageNamed:@"papasscode_failed_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, FAILED_LCAP, 0, FAILED_RCAP)];
    failedImageView = [[UIImageView alloc] initWithImage:failedBg];
    failedImageView.hidden = YES;
    [view addSubview:failedImageView];
    
    failedAttemptsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    failedAttemptsLabel.backgroundColor = [UIColor clearColor];
    failedAttemptsLabel.textColor = [UIColor whiteColor];
    failedAttemptsLabel.font = [UIFont boldSystemFontOfSize:15];
    failedAttemptsLabel.shadowColor = [UIColor blackColor];
    failedAttemptsLabel.shadowOffset = CGSizeMake(0, -1);
    failedAttemptsLabel.textAlignment = UITextAlignmentCenter;
    failedAttemptsLabel.hidden = YES;
    [view addSubview:failedAttemptsLabel];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_failedAttempts > 0) {
        [self showFailedAttempts];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showScreenForPhase:0 animated:NO];
    [passcodeTextField becomeFirstResponder];
}

- (void)cancel:(id)sender {
    [_delegate PAPasscodeViewControllerDidCancel:self];
}

#pragma mark - implementation helpers

- (void)handleFailedAttempt {
    _failedAttempts++;
    [self showFailedAttempts];
    if ([_delegate respondsToSelector:@selector(PAPasscodeViewController:didFailToEnterPasscode:)]) {
        [_delegate PAPasscodeViewController:self didFailToEnterPasscode:_failedAttempts];
    }
}

- (void)resetFailedAttempts {
    messageLabel.hidden = NO;
    failedImageView.hidden = YES;
    failedAttemptsLabel.hidden = YES;
    _failedAttempts = 0;
}

- (void)showFailedAttempts {
    messageLabel.hidden = YES;
    failedImageView.hidden = NO;
    failedAttemptsLabel.hidden = NO;
    if (_failedAttempts == 1) {
        failedAttemptsLabel.text = NSLocalizedString(@"1 Failed Passcode Attempt", nil);
    } else {
        failedAttemptsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Failed Passcode Attempts", nil), _failedAttempts];
    }
    [failedAttemptsLabel sizeToFit];
    CGFloat bgWidth = failedAttemptsLabel.bounds.size.width + FAILED_MARGIN*2;
    CGFloat x = floor((self.view.bounds.size.width-bgWidth)/2);
    CGFloat y = PROMPT_HEIGHT+DIGIT_HEIGHT+floor((MESSAGE_HEIGHT-FAILED_HEIGHT)/2);
    failedImageView.frame = CGRectMake(x, y, bgWidth, FAILED_HEIGHT);
    x = failedImageView.frame.origin.x+FAILED_MARGIN;
    y = failedImageView.frame.origin.y+floor((failedImageView.bounds.size.height-failedAttemptsLabel.frame.size.height)/2);
    failedAttemptsLabel.frame = CGRectMake(x, y, failedAttemptsLabel.bounds.size.width, failedAttemptsLabel.bounds.size.height);
}

- (void)passcodeChanged:(id)sender {
    NSString *text = passcodeTextField.text;
    if ([text length] > 4) {
        text = [text substringToIndex:4];
    }
    for (int i=0;i<4;i++) {
        digitImageViews[i].hidden = i >= [text length];
    }
    if ([text length] < 4) {
        return;
    }
    switch (_action) {
        case PasscodeActionSet:
            if (phase == 0) {
                _passcode = text;
                messageLabel.text = @"";
                [self showScreenForPhase:1 animated:YES];
            } else {
                if ([text isEqualToString:_passcode]) {
                    if ([_delegate respondsToSelector:@selector(PAPasscodeViewControllerDidSetPasscode:)]) {
                        [_delegate PAPasscodeViewControllerDidSetPasscode:self];
                    }
                } else {
                    [self showScreenForPhase:0 animated:YES];
                    messageLabel.text = NSLocalizedString(@"Passcodes did not match. Try again.", nil);
                }
            }
            break;

        case PasscodeActionEnter:
            if ([text isEqualToString:_passcode]) {
                [self resetFailedAttempts];
                if ([_delegate respondsToSelector:@selector(PAPasscodeViewControllerDidEnterPasscode:)]) {
                    [_delegate PAPasscodeViewControllerDidEnterPasscode:self];
                }
            } else {
                [self handleFailedAttempt];
                [self showScreenForPhase:0 animated:NO];
            }
            break;

        case PasscodeActionChange:
            if (phase == 0) {
                if ([text isEqualToString:_passcode]) {
                    [self resetFailedAttempts];
                    [self showScreenForPhase:1 animated:YES];
                } else {
                    [self handleFailedAttempt];
                    [self showScreenForPhase:0 animated:NO];
                }
            } else if (phase == 1) {
                _passcode = text;
                messageLabel.text = @"";
                [self showScreenForPhase:2 animated:YES];
            } else {
                if ([text isEqualToString:_passcode]) {
                    if ([_delegate respondsToSelector:@selector(PAPasscodeViewControllerDidChangePasscode:)]) {
                        [_delegate PAPasscodeViewControllerDidChangePasscode:self];
                    }
                } else {
                    [self showScreenForPhase:1 animated:YES];
                    messageLabel.text = NSLocalizedString(@"Passcodes did not match. Try again.", nil);
                }
            }
            break;
    }
}

- (void)showScreenForPhase:(NSInteger)newPhase animated:(BOOL)animated {
    CGFloat dir = (newPhase > phase) ? 1 : -1;
    if (animated) {
        
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        snapshotImageView = [[UIImageView alloc] initWithImage:snapshot];
        snapshotImageView.frame = CGRectOffset(snapshotImageView.frame, -self.view.frame.size.width*dir, 0);
        [self.view addSubview:snapshotImageView];
    }
    phase = newPhase;
    passcodeTextField.text = @"";
    
    switch (_action) {
        case PasscodeActionSet:
            if (phase == 0) {
                promptLabel.text = _enterPrompt;
            } else {
                promptLabel.text = _confirmPrompt;
            }
            break;
            
        case PasscodeActionEnter:
            promptLabel.text = _enterPrompt;
            break;
            
        case PasscodeActionChange:
            if (phase == 0) {
                promptLabel.text = _changePrompt;
            } else if (phase == 1) {
                promptLabel.text = _enterPrompt;
            } else {
                promptLabel.text = _confirmPrompt;
            }
            break;
    }
    for (int i=0;i<4;i++) {
        digitImageViews[i].hidden = YES;
    }
    if (animated) {
        self.view.frame = CGRectOffset(self.view.frame, self.view.frame.size.width*dir, 0);
        [UIView animateWithDuration:SLIDE_DURATION animations:^() {
            self.view.frame = CGRectOffset(self.view.frame, -self.view.frame.size.width*dir, 0);
        } completion:^(BOOL finished) {
            [snapshotImageView removeFromSuperview];
            snapshotImageView = nil;
        }];
    }
}

@end
