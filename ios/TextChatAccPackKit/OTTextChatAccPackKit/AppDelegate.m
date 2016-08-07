//
//  AppDelegate.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <OTTextChatKit/OTTextChatKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [OTTextChat setOpenTokApiKey:@"45629512"
                       sessionId:@"2_MX40NTYyOTUxMn5-MTQ2OTg1ODU3MzIzM35MblV5VFB6VHpZK0ZWckU0V1lycDVnY3J-fg"
                           token:@"T1==cGFydG5lcl9pZD00NTYyOTUxMiZzaWc9NzA3MTQyODUxZTM1NmIwNDRhZGM5MDM1ZDQ5NDQ1MjBlNzFjYmZhZDpzZXNzaW9uX2lkPTJfTVg0ME5UWXlPVFV4TW41LU1UUTJPVGcxT0RVM016SXpNMzVNYmxWNVZGQjZWSHBaSzBaV2NrVTBWMWx5Y0RWblkzSi1mZyZjcmVhdGVfdGltZT0xNDY5ODU4NTgwJm5vbmNlPTAuMzQyODY1Mjg4OTU2MDkwOCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNDcyNDUwNTc5"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
