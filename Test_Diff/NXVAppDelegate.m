#import "NXVAppDelegate.h"

@implementation NXVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NXVDiffViewController *diffViewController = [NXVDiffViewController new];
    _window.rootViewController = diffViewController;
    
    [_window makeKeyAndVisible];
    return YES;
}

@end
