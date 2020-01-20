//
//  AppDelegate.m
//  GAVideoRecordDemo
//
//  Created by apple on 2020/1/19.
//  Copyright © 2020 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    HomeViewController *home = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = home;
    [self.window makeKeyWindow];
    return YES;
}

@end
