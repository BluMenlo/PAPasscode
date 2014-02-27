//
//  ViewController.m
//  PAPasscode Example
//
//  Created by Denis Hennessy on 15/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent inNavControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UINavigationController *containerNav = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
    [self presentViewController:containerNav animated:flag completion:completion];
}

- (IBAction)setPasscode:(id)sender {
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    [self presentViewController:passcodeViewController inNavControllerAnimated:YES completion:nil];
}

- (IBAction)enterPasscode:(id)sender {
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.passcode = _passcodeLabel.text;
    passcodeViewController.alternativePasscode = @"9999";
    [self presentViewController:passcodeViewController inNavControllerAnimated:YES completion:nil];
}

- (IBAction)changePasscode:(id)sender {
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionChange];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    passcodeViewController.passcode = _passcodeLabel.text;
    [self presentViewController:passcodeViewController inNavControllerAnimated:YES completion:nil];
}

#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidEnterAlternativePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Alternative Passcode entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Passcode entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        _passcodeLabel.text = controller.passcode;
    }];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        _passcodeLabel.text = controller.passcode;
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
