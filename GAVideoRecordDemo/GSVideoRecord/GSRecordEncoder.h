//
//  GSRecordEncoder.h
//  Demo
//
//  Created by Demo on 2019/3/6.
//  Copyright © 2019年 Demo. All rights reserved.
//  视频编码类

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSRecordEncoder : NSObject

@property (nonatomic, readonly) NSString *path;

/**
 *  GSRecordEncoder遍历构造器的
 *
 *  @param path 媒体存发路径
 *  @param cy   视频分辨率的高
 *  @param cx   视频分辨率的宽
 *  @param ch   音频通道
 *  @param rate 音频的采样比率
 *
 *  @return GSRecordEncoder的实体
 */
+ (GSRecordEncoder *)encoderForPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels: (int)ch samples:(Float64)rate;

/**
 *  初始化方法
 *
 *  @param path 媒体存发路径
 *  @param cy   视频分辨率的高
 *  @param cx   视频分辨率的宽
 *  @param ch   音频通道
 *  @param rate 音频的采样率
 *
 *  @return GSRecordEncoder的实体
 */
- (instancetype)initPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels: (int)ch samples:(Float64)rate;

/**
 *  完成视频录制时调用
 *
 *  @param handler 完成的回掉block
 */
- (void)finishWithCompletionHandler:(void (^)(void))handler;

/**
 *  通过这个方法写入数据
 *
 *  @param sampleBuffer 写入的数据
 *  @param isVideo      是否写入的是视频
 *
 *  @return 写入是否成功
 */
- (BOOL)encodeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;
@end

NS_ASSUME_NONNULL_END
