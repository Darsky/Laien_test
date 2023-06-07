//
//  AppDelegate.m
//  oc_teacher_phone
//
//  Created by 朱伟铭 on 2020/7/7.
//  Copyright © 2020 朱伟铭. All rights reserved.
//

#import "AppDelegate.h"
#import "OCFMDBHelper.h"
#import "ClockInViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [OCFMDBHelper shareFMDBHelper];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window resignKeyWindow];
    [self.window makeKeyAndVisible];
    

    self.window.rootViewController = [[ClockInViewController alloc] initWithNibName:@"ClockInViewController"
                                                                                  bundle:nil];
    return YES;
}



@end
