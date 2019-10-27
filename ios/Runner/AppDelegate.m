#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
    if(![FIRApp defaultApp]) {
        [FIRApp configure];
    }
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidFinishLaunching:(UIApplication *)app {
    // Configure the user interactions first.
    [self configureUserInteractions];
 
   // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
 
// Handle remote notification registration.
- (void)application:(UIApplication *)app
        didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    // Forward the token to your provider, using a custom method.
    [self enableRemoteNotificationFeatures];
//    [self forwardTokenToServer:devTokenBytes];
}
 
- (void)application:(UIApplication *)app
        didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);
    [self disableRemoteNotificationFeatures];
}

@end
