//
//  UIViewController+NoSlideBack.m
//  Demo
//
//  Created by Demo on 2019/3/4.
//  Copyright © 2019年 Demo. All rights reserved.
//

#import "UIViewController+NoSlideBack.h"

@implementation UIViewController (NoSlideBack)

- (void)configNoSlideBack {
    // 禁止侧滑返回
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

@end
