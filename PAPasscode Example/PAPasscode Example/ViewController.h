//
//  ViewController.h
//  PAPasscode Example
//
//  Created by Denis Hennessy on 15/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPasscodeViewController.h"

@interface ViewController : UIViewController <PAPasscodeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *passcodeLabel;

- (IBAction)setPasscode:(id)sender;
- (IBAction)enterPasscode:(id)sender;
- (IBAction)changePasscode:(id)sender;

@end
