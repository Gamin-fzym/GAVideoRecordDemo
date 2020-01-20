//
//  GSRecordVideoController.h
//  Demo
//
//  Created by Demo on 2019/3/6.
//  Copyright © 2019年 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GSRecordVideoControllerDelegate <NSObject>
@required

/**
 处理录像回调

 @param recordPath 生成录像的路径 (播放器播放此路径即可, 类似该类中openPlayerWithPath方法打开路径播放~)
 @param firstImage 生成录像的首帧图
 @param totalTimeFormat 生成录像的时长格式化(00:00)
 */
- (void)handleWithRecordPath:(NSString *)recordPath withFirstImage:(UIImage *)firstImage withTotalTimeFormat:(NSString *)totalTimeFormat;

@end

@interface GSRecordVideoController : UIViewController

@property (nonatomic, weak) id <GSRecordVideoControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger limitSecs; // 限制录制秒数 - 默认120s

@end

NS_ASSUME_NONNULL_END
