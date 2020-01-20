//
//  GSPSVideoCell.m
//  GAVideoRecordDemo
//
//  Created by Gamin on 2019/3/11.
//  Copyright © 2019年 Gamin. All rights reserved.
//

#import "GSPSVideoCell.h"

@interface GSPSVideoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *videoImg;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@end

@implementation GSPSVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configViews {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playClick)];
    [self.maskV addGestureRecognizer:tap];
}

- (void)setVideoModel:(GSPSVideoModel *)videoModel {
    _videoModel = videoModel;
    if (videoModel) {
        self.videoImg.image = videoModel.videoFirstImg;
        self.timeLbl.text = videoModel.videoTimeFormat;
    }
}

- (void)playClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(GSPSVideoCell_PlayClickWithPath:)]) {
        [self.delegate GSPSVideoCell_PlayClickWithPath:_videoModel.videoLocalPath];
    }
    
    if (_videoModel.videoLocalPath != nil && ![_videoModel.videoLocalPath isEqualToString:@""]) {
        NSString *urlPath = self.videoModel.videoLocalPath;
        if (![self theString:urlPath containSting:@"file://"]) {
            urlPath = [NSString stringWithFormat:@"file://%@",urlPath];
        }
        NSIndexPath *_curIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self setupPlayerViewWithIndex:_curIndexPath Path:urlPath First:YES];
    }
}

- (BOOL)theString:(NSString *)str containSting:(NSString *)string {
    if (str && [str rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (IBAction)tapPlayButtonAction:(id)sender {
    
}

// 设置播放器
- (void)setupPlayerViewWithIndex:(NSIndexPath *)index Path:(NSString *)path First:(BOOL)first {
    GASLPlayer *sharePlayer = [GASLPlayer sharedGASLPlayerMethod];
    SLPlayerView *playerView = sharePlayer.playerView;
    UITableView *collView = (UITableView *)[self superview];
    [_maskV addSubview:playerView];
    [playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_maskV);
        make.left.mas_equalTo(_maskV);
        make.right.mas_equalTo(_maskV);
        make.bottom.mas_equalTo(_maskV);
    }];
    if (first) {
        SLPlayerModel *playerModel = [[SLPlayerModel alloc] init];
        playerModel.videoURL       = [NSURL URLWithString:path];
        playerModel.scrollView     = collView;
        playerModel.indexPath      = index;
        playerModel.fatherViewTag  = 200;
        [sharePlayer playWithPlayerModel:playerModel];
    }
}


@end
