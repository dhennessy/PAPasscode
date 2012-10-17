# PAPasscode

PAPasscode is a standalone view controller for iOS to allow a user to set, 
enter or change a passcode. It's design to mimic the behaviour in Settings.app
while still allowing some customization. It includes a sample project which
shows how it appears on iPhone and iPad devices.

Other features:
 *	Supports both simple (PIN-style) and regular passcodes
 *	Allows customization of title and prompts
 *  Animates screens left and right
 *	Requires ARC

## Adding PAPasscode to your project

The simplest way to add PAPasscode to your project is to use [CocoaPods](http://cocoapods.org). 
Simply add the following line to your Podfile:

```
	pod 'PAPasscode'
```

If you'd prefer to manually integrate it, simply copy `PAPasscode/*.{m,h}` and `Assets/*.png` 
into your project.  Make sure you link with the QuartzCore framework.

## Asking the user to set a passcode

First, implement the following delegate methods on your view controller:

```objective-c
- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
	// Do stuff with controller.passcode...
    [self dismissViewControllerAnimated:YES completion:nil];
}
```

Then invoke the view controller as follows:

```objective-c
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    passcodeViewController.delegate = self;
    [self presentViewController:passcodeViewController animated:YES completion:nil];
```

