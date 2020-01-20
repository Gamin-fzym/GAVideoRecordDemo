//
//  GSRecordVideoController.m
//  Demo
//
//  Created by Demo on 2019/3/6.
//  Copyright © 2019年 Demo. All rights reserved.
//

#import "GSRecordVideoController.h"

#import "GSRecordEngine.h"
#import "GSRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+Toast.h"

#define Animation_OffsetY   120

typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};

@interface GSRecordVideoController () <GSRecordEngineDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stopRecordLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userRecTrailiing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stopRecY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *useRecY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recY;

@property (weak, nonatomic) IBOutlet UIButton *closePageBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashLightBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraBtn;

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *noUseRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *useRecordBtn;

@property (strong, nonatomic) GSRecordEngine *recordEngine;
@property (assign, nonatomic) BOOL allowRecord; // 允许录制
@property (assign, nonatomic) UploadVieoStyle videoStyle; // 视频的类型
@property (strong, nonatomic) UIImagePickerController *moviePicker; // 视频选择器
// MP_DEPRECATED("Use AVPlayerViewController in AVKit.", ios(3.2, 9.0))
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (strong, nonatomic) AVPlayer *zjPlayer;
@property (nonatomic, strong) AVPlayerItem  *zjPlayerItem;
@property (nonatomic, strong) AVPlayerLayer *zjPlayerLayer;
@property (nonatomic, strong) AVURLAsset *zjUrlAsset;
@property (nonatomic, assign) BOOL isPlayEnd; // 是否播放完成

@property (strong, nonatomic) UIImage *recordImg; // 录制好视频后的第一张图
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSInteger timeSecs;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeCenterY;

@end

@implementation GSRecordVideoController

#pragma mark 配置

- (void)dealloc {
    _recordEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:[_playerVC moviePlayer]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];;

    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [self.recordEngine shutdown];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVars];
    [self configConstrains];
    [self configViews];
}

- (void)initVars {
    self.allowRecord = YES;
    self.timeSecs = 0;
}

- (void)resetTime {
    self.timeSecs = 0;
    self.timeLbl.text = @"00:00";
}

- (void)configConstrains {
    self.stopRecordLeading.constant = (CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.noUseRecordBtn.frame)-CGRectGetWidth(self.useRecordBtn.frame)-CGRectGetWidth(self.recordBtn.frame))/4.0;
    self.userRecTrailiing.constant = self.stopRecordLeading.constant;
    if (iPhoneX) {
        self.closeCenterY.constant = 20.0;
    } else {
        self.closeCenterY.constant = 0.0;
    }
}

- (void)configViews {
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = KWindow.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}

// 开录动画
- (void)startRecAnima {
    if (self.stopRecY.constant != Animation_OffsetY) {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.stopRecY.constant += Animation_OffsetY;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.4 delay:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recY.constant -= Animation_OffsetY;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.useRecY.constant += Animation_OffsetY;
            // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

// 停录动画
- (void)stopRecAnima {
    if (self.stopRecY.constant != 0) {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.stopRecY.constant -= Animation_OffsetY;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.4 delay:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recY.constant += Animation_OffsetY;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.useRecY.constant -= Animation_OffsetY;
            // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - 懒加载

- (GSRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[GSRecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    return _moviePicker;
}

- (dispatch_source_t)timer {
    if (!_timer) {
        // 创建GCD定时器
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(self.timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self timerHandle];
            });
        });
    }
    return _timer;
}

#pragma mark - 代理

- (void)recordProgress:(CGFloat)progress {
    /*
    if (progress >= 1) {//超过限时就停止录像
        [self recordClick:self.recordBtn];
        self.allowRecord = NO;
    }
     */
}

#pragma mark - 相册选择代理
// 选择了某个照片的回调函数/代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        // 获取视频的名称
        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
//        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
//        NSString *content=[videoPath substringFromIndex:range.location+5];
//        //视频的后缀
//        NSRange rangeSuffix=[content rangeOfString:@"."];
//        NSString * suffixName=[content substringFromIndex:rangeSuffix.location+1];
        // 如果视频是mov格式的则转为MP4的
        if ([self theString:videoPath containSting:@".MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            __weak typeof(self) weakSelf = self;
            [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
                
                [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
                    [weakSelf sureRecordClick:nil];
                }];
            }];
        }
    }
}

- (BOOL)theString:(NSString *)str containSting:(NSString *)string {
    if (str && [str rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}

#pragma mark 事件
// 关闭页面
- (IBAction)closeClick:(id)sender {
    if (_recordEngine.videoPath.length > 0) {
        WEAKSELF
        [self.recordEngine stopCaptureHandler:^(UIImage * _Nonnull movieImage) {
            weakSelf.recordImg = movieImage;
        }];
        [self stopRecAnima];
    }
    // 取消定时器
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// 闪光灯开关
- (IBAction)flashlightClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        // 开
        [self.recordEngine openFlashLight];
    } else {
        // 关
       [self.recordEngine closeFlashLight];
    }
}

// 切换前后摄像头
- (IBAction)changeCameraClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        // 前置
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    } else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}

// 录制
- (IBAction)recordClick:(UIButton *)sender {
    if (self.allowRecord) {
        self.videoStyle = VideoRecord;
        sender.selected = !sender.isSelected;
        if (sender.isSelected) { // 开录
            [self.recordEngine startCapture];
            [self startRecAnima];
            // 开启定时器
            dispatch_resume(self.timer);
        } else { // 停止(录完)
            if (_recordEngine.videoPath.length > 0) {
                WEAKSELF
                [self.recordEngine stopCaptureHandler:^(UIImage * _Nonnull movieImage) {
                    weakSelf.recordImg = movieImage;
                }];
                [self stopRecAnima];
                
                [self performSelector:@selector(yancChuliAction) withObject:nil afterDelay:1];
            }
            // 取消定时器
            if (_timer) {
                dispatch_source_cancel(_timer);
                _timer = nil;
                // [self resetTime];
            }
        }
    }
}

- (void)yancChuliAction {
    [self.recordEngine shutdown];
    [self setupZJPlayer];
}

// 不要录制好的 - 可重新录
- (IBAction)cancelRecordClick:(id)sender {
    [self zjStopPlayer];
    [_recordEngine startUp];

    [self resetTime];
    [self startRecAnima];
}

// 使用录制好的
- (IBAction)sureRecordClick:(id)sender {
    [self zjStopPlayer];
    
    NSString *totalTimeStr = self.timeLbl.text;
    [self resetTime];
    if (_recordEngine.videoPath.length > 0) {
        // [self openPlayerWithPath:self.recordEngine.videoPath];
        if (self.delegate && [self.delegate respondsToSelector:@selector(handleWithRecordPath:withFirstImage:withTotalTimeFormat:)]) {
            [self.delegate handleWithRecordPath:_recordEngine.videoPath withFirstImage:self.recordImg withTotalTimeFormat:totalTimeStr];
        }
        [self closeClick:nil];
    } else {
        [self.view makeToast:@"请先录制视频!"];
    }
}

// 播放、暂停按钮
- (IBAction)playOrPauseAction:(id)sender {
    if (_zjPlayer) {
        if (_zjPlayer.rate == 0) {
            if (_isPlayEnd == YES) {
                _isPlayEnd = NO;
                [_zjPlayer seekToTime:kCMTimeZero];
                [_zjPlayer play];
            } else {
                [_zjPlayer play];
            }
        } else {
            [_zjPlayer pause];
        }
    }
}

// 播放完成
- (void)handlePlayEnd {
    _isPlayEnd = YES;
}

// 初始化播放器
- (void)setupZJPlayer {
    NSString *nowVideoPath = self.recordEngine.videoPath;
    if (![self theString:nowVideoPath containSting:@"file://"]) {
        nowVideoPath = [NSString stringWithFormat:@"file://%@",nowVideoPath];
    }
    _zjUrlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:nowVideoPath]];
    _zjPlayerItem = [AVPlayerItem playerItemWithAsset:_zjUrlAsset];//[AVPlayerItem playerItemWithURL:[NSURL URLWithString:nowVideoPath]];
    if (!_zjPlayer) {
        _zjPlayer = [[AVPlayer alloc] init];
        // 接收播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    [_zjPlayer replaceCurrentItemWithPlayerItem:_zjPlayerItem];
    //_zjPlayer = [AVPlayer playerWithPlayerItem:_zjPlayerItem];
    if (!_zjPlayerLayer) {
        _zjPlayerLayer = [[AVPlayerLayer alloc] init];
    }
    _zjPlayerLayer.player = _zjPlayer;
    //_zjPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_zjPlayer];
    _zjPlayerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    _zjPlayerLayer.videoGravity = AVLayerVideoGravityResize; // 非均匀模式。两个维度完全填充至整个视图区域

    // UIView *fcView = [self.view viewWithTag:678];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self.view.layer insertSublayer:_zjPlayerLayer atIndex:1];
    [_zjPlayer play];
}

// 停止视频播放
- (void)zjStopPlayer {
    [_zjPlayer pause];
    [_zjPlayerLayer removeFromSuperlayer];
}

#pragma mark - 其它

- (void)openPlayerWithPath:(NSString *)path {
    if (path.length > 0) {
        self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[self.playerVC moviePlayer]];
        [[self.playerVC moviePlayer] prepareToPlay];
        
        [self presentMoviePlayerViewControllerAnimated:self.playerVC];
        [[self.playerVC moviePlayer] play];
    }
}

// 当点击Done按键或者播放完毕时调用此函数
- (void)playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}

// 定时器
- (void)configSecTimer {
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerHandle];
        });
    });
    // 开启定时器
    dispatch_resume(self.timer);
}

- (void)timerHandle {
    self.timeLbl.text = [self Timeformat2FromSeconds:self.timeSecs];
    NSInteger limitSecs = self.limitSecs?:GS_Video_Limit_Seconds;
    if (self.timeSecs >= limitSecs) { // 限制录制时长
        NSString *limitSecsStr = [NSString stringWithFormat:@"最长只能录制%ld秒", limitSecs];
        [KWindow makeToast:limitSecsStr duration:1.5 position:CSToastPositionBottom];
        [self recordClick:self.recordBtn];
    }
    self.timeSecs ++;
}

- (NSString*)Timeformat2FromSeconds:(NSInteger)seconds {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time;
    if ([str_hour isEqualToString:@"00"]) {
         format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    else format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

@end
