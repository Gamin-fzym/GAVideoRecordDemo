//
//  GSRecordProgressView.h
//  Demo
//
//  Created by Demo on 2019/3/6.
//  Copyright © 2019年 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSRecordProgressView : UIView
@property (assign, nonatomic) IBInspectable CGFloat progress;//当前进度
@property (strong, nonatomic) IBInspectable UIColor *progressBgColor;//进度条背景颜色
@property (strong, nonatomic) IBInspectable UIColor *progressColor;//进度条颜色
@property (assign, nonatomic) CGFloat loadProgress;//加载好的进度
@property (strong, nonatomic) UIColor *loadProgressColor;//已经加载好的进度颜色
@end

NS_ASSUME_NONNULL_END
