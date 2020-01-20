//
//  GSPSVideoCell.h
//  GAVideoRecordDemo
//
//  Created by Gamin on 2019/3/11.
//  Copyright © 2019年 Gamin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSPSVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const GSPSVideoCellIdentifier = @"GSPSVideoCell";

@protocol GSPSVideoCellDelegate <NSObject>

@optional

- (void)GSPSVideoCell_PlayClickWithPath:(NSString *)playPath;

@end

@interface GSPSVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *maskV;
@property (nonatomic, strong) GSPSVideoModel *videoModel;
@property (nonatomic, weak) id <GSPSVideoCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
