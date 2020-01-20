//
//  UIViewController+Present.h
//  GAVideoRecordDemo
//
//  Created by Gamin on 2019/10/9.
//  Copyright © 2019 Gamin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Present)

@property (nonatomic, assign) BOOL LL_automaticallySetModalPresentationStyle;

+ (BOOL)LL_automaticallySetModalPresentationStyle;

@end

NS_ASSUME_NONNULL_END
