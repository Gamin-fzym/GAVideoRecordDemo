//
//  GASLPlayer.m
//  Midoutu
//
//  Created by apple on 2019/11/29.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "GASLPlayer.h"

static GASLPlayer *sharedGASLPlayer = nil;

@implementation GASLPlayer

+ (id)sharedGASLPlayerMethod {
    @synchronized (self){
        if (!sharedGASLPlayer) {
            sharedGASLPlayer = [[GASLPlayer alloc] init];
            [sharedGASLPlayer playerView];
        }
        return sharedGASLPlayer;
    }
    return sharedGASLPlayer;
}

- (SLPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [SLPlayerView sharedPlayerView];
        _playerView.playerLayerGravity = SLPlayerLayerGravityResizeAspect;
        _playerView.cellPlayerOnCenter = NO;
        _playerView.hasPreviewView = YES;
        _playerView.stopPlayWhileCellNotVisable = YES;
        _playerView.delegate = self;
    }
    return _playerView;
}

- (SLPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[SLPlayerControlView alloc] init];
    }
    return _controlView;
}

- (void)playWithPlayerModel:(SLPlayerModel *)playerModel {
    [self.playerView playerControlView:self.controlView playerModel:playerModel];
    [self.playerView autoPlayTheVideo];
}

@end
