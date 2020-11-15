#include <spawn.h>

@interface SBApplicationInfo
- (NSArray *)tags;
- (NSString *)displayName;
- (NSURL *)bundleURL;
@end

@interface SBApplication
- (SBApplicationInfo *)info;
- (bool)iconCompleteUninstall:(id)arg1;
@end

@interface SBIcon
- (SBApplication *)application;
- (NSString *)applicationBundleID;
- (BOOL)isUninstalled;
@end

@interface SBIconView
- (SBIcon *)icon;
- (bool)isCydiaIcon;
@end

@interface SBIconController : NSObject
- (void)cyDelete:(SBIconView *)iconView;
- (void)cyDeleteAlert:(SBIconView *)iconView;
- (void)uninstallIcon:(SBIcon *)icon animate:(BOOL)animate;
@end

@interface SBXCloseBoxView : UIButton
@end

@interface LSApplicationWorkspace
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)unregisterApplication:(NSURL *)application;
@end

%hook SBApplicationInfo
- (NSUInteger)uninstallCapability {
	if (([[[self tags] objectAtIndex:0] containsString:@"SBNonDefaultSystemAppTag"]) && (![[self displayName] isEqualToString:@"Cydia"]) && (![[self displayName] isEqualToString:@"Sileo"])) {
		return 1;
	}
	return %orig;
}
%end

%hook SBIconView
%new
- (bool)isCydiaIcon {
	if (([[[[[[self icon] application] info] tags] objectAtIndex:0] containsString:@"SBNonDefaultSystemAppTag"]) && (![[[[[self icon] application] info] displayName] isEqualToString:@"Cydia"]) && (![[[[[self icon] application] info] displayName] isEqualToString:@"Sileo"])) {
		return true;
	}
	return false;
}
%end

%hook SBIconController
- (void)iconCloseBoxTapped:(id)arg1 {
	SBIconView *iconView = arg1;
	if ([iconView isCydiaIcon]) {
		[self cyDeleteAlert:arg1];
	} else{
		%orig;
	}
}
%new
- (void)cyDeleteAlert:(SBIconView *)iconView {
	NSString *displayName = [[[[iconView icon] application] info] displayName];
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	UIAlertController *alert= [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Delete \"%@\"?", displayName] message:@"Deleting this app will also delete its data and may respring your device" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
    [self cyDelete:iconView];
  }];
  UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		[alert dismissViewControllerAnimated:YES completion:nil];
	}];
	[alert addAction:cancel];
	[alert addAction:ok];
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}
	[topController presentViewController:alert animated:YES completion:nil];
}
%new
- (void)cyDelete:(SBIconView *)iconView {
	NSURL *appURL = [[[[iconView icon] application] info] bundleURL];
	NSString *appURLStr = [[[[[iconView icon] application] info] bundleURL] absoluteString];
	NSString *appString = [appURLStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
	const char *app = [appString cStringUsingEncoding:NSUTF8StringEncoding];
	[[%c(LSApplicationWorkspace) defaultWorkspace] unregisterApplication:appURL];
	[self uninstallIcon:[iconView icon] animate:YES];
	pid_t pid;
  const char *args[] = {"sudo", "/usr/libexec/cydelete", app, NULL};
  posix_spawn(&pid, "/usr/bin/sudo", NULL, NULL, (char *const *)args, NULL);
}
%end