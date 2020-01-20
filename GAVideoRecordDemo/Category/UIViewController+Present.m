//
//  UIViewController+Present.m
//  GAVideoRecordDemo
//
//  Created by Gamin on 2019/10/9.
//  Copyright © 2019 Gamin. All rights reserved.
//

#import "UIViewController+Present.h"
#import <objc/runtime.h>

static const char *LL_automaticallySetModalPresentationStyleKey;

@implementation UIViewController (Present)

+ (void)load {
    Method originAddObserverMethod = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
    Method swizzledAddObserverMethod = class_getInstanceMethod(self, @selector(LL_presentViewController:animated:completion:));
    method_exchangeImplementations(originAddObserverMethod, swizzledAddObserverMethod);
}

- (void)setLL_automaticallySetModalPresentationStyle:(BOOL)LL_automaticallySetModalPresentationStyle {
    objc_setAssociatedObject(self, LL_automaticallySetModalPresentationStyleKey, @(LL_automaticallySetModalPresentationStyle), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)LL_automaticallySetModalPresentationStyle {
    id obj = objc_getAssociatedObject(self, LL_automaticallySetModalPresentationStyleKey);
    if (obj) {
        return [obj boolValue];
    }
    return [self.class LL_automaticallySetModalPresentationStyle];
}

+ (BOOL)LL_automaticallySetModalPresentationStyle {
    if ([self isKindOfClass:[UIImagePickerController class]] || [self isKindOfClass:[UIAlertController class]]) {
        return NO;
    }
    return YES;
}

- (void)LL_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (@available(iOS 13.0, *)) {
        if (viewControllerToPresent.LL_automaticallySetModalPresentationStyle) {
            if ([self haveSetTransition]) {
                viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                viewControllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
            } else {
                viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
            }
            viewControllerToPresent.modalInPresentation = YES;
        }
        [self LL_presentViewController:viewControllerToPresent animated:flag completion:completion];
    } else {
        // Fallback on earlier versions
        [self LL_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

- (BOOL)haveSetTransition {
    BOOL result = YES;
//    if ([self isKindOfClass:[GSReportViewController class]]) {
//        result = NO;
//    }
    return result;
}

@end
