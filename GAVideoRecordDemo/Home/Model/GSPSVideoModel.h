//
//  GSPSVideoModel.h
//  GAVideoRecordDemo
//
//  Created by Gamin on 2019/3/11.
//  Copyright © 2019年 Gamin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSPSVideoModel : NSObject

@property (nonatomic, copy  ) NSString *videoLocalPath;//录像本地路径
@property (nonatomic, strong) UIImage  *videoFirstImg;//录像首帧图
@property (nonatomic, copy  ) NSString *videoTimeFormat;//录像时长

@property (nonatomic, copy  ) NSString *videoText;//说点什么
@property (strong, nonatomic) NSString *groupId;//圈子id

@end

NS_ASSUME_NONNULL_END
