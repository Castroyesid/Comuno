#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TWTRKit.h>
#import <Crashlytics/Crashlytics.h>
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate : FlutterAppDelegate

- (void)configureUserInteractions;

- (void)enableRemoteNotificationFeatures;

- (void)forwardTokenToServer:devTokenBytes;

- (void)disableRemoteNotificationFeatures;

@end
