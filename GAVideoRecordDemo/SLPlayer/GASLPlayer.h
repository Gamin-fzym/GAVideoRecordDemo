//
//  GASLPlayer.h
//  Midoutu
//
//  Created by apple on 2019/11/29.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GASLPlayer : NSObject <SLPlayerDelegate>

@property (nonatomic, strong) SLPlayerView *playerView;
@property (nonatomic, strong) SLPlayerControlView *controlView;

+ (id)sharedGASLPlayerMethod;

- (void)playWithPlayerModel:(SLPlayerModel *)playerModel;

@end

NS_ASSUME_NONNULL_END
