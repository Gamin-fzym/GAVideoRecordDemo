//
//  HomeViewController.m
//  GAVideoRecordDemo
//
//  Created by Gamin on 2020/1/19.
//  Copyright © 2020 Gamin. All rights reserved.
//

#import "HomeViewController.h"
#import "GSRecordVideoController.h"
#import "GSRecordEngine.h"
#import <CoreServices/CoreServices.h>
#import "UIViewController+NoSlideBack.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, GSPSVideoCellDelegate, GSRecordVideoControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImagePickerController *moviePicker; // 视频选择器
@property (strong, nonatomic) GSRecordEngine *recordEngine;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:GSPSVideoCellIdentifier bundle:nil] forCellReuseIdentifier:GSPSVideoCellIdentifier];

}

- (IBAction)tapAddVideoAction:(id)sender {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:self.moviePicker animated:YES completion:nil];
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       GSRecordVideoController *con = GSRecordVideoController.new;
       con.hidesBottomBarWhenPushed = YES;
       con.delegate = self;
       [self presentViewController:con animated:YES completion:nil];
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark - 懒加载
- (GSRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[GSRecordEngine alloc] init];
    }
    return _recordEngine;
}

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        [_moviePicker configNoSlideBack];
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        _moviePicker.allowsEditing = YES;
        _moviePicker.videoMaximumDuration = GS_Video_Limit_Seconds;
    }
    return _moviePicker;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSPSVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:GSPSVideoCellIdentifier forIndexPath:indexPath];
    videoCell.videoModel = self.videoModel;
    videoCell.delegate = self;
    return videoCell;
}

#pragma mark - GSPSVideoCellDelegate

- (void)GSPSVideoCell_PlayClickWithPath:(NSString *)playPath {
    
}

#pragma mark - GSRecordVideoControllerDelegate
// 录像
- (void)handleWithRecordPath:(NSString *)recordPath withFirstImage:(UIImage *)firstImage withTotalTimeFormat:(NSString *)totalTimeFormat {
    GSPSVideoModel *videoModel = GSPSVideoModel.new;
    videoModel.videoLocalPath = recordPath;
    videoModel.videoFirstImg = firstImage;
    videoModel.videoTimeFormat = totalTimeFormat;
    self.videoModel = videoModel;
    [self.tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate
// 选择视频
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        // 获取视频的名称
        NSString *videoPath = [NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
        // 如果视频是mov格式的则转为MP4的
        if ([videoPath containsString:@".MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            CGFloat timeSecs = [self getVideoDuration:videoUrl];
            
            NSString *timeFormat = [self Timeformat2FromSeconds:timeSecs];
            WEAKSELF
            [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
                [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
                    [self handleWithRecordPath:weakSelf.recordEngine.videoPath withFirstImage:movieImage withTotalTimeFormat:timeFormat];
                }];
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 其它
// 获取视频时间
- (CGFloat)getVideoDuration:(NSURL *)URL {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

// 获取视频 大小
- (NSInteger)getFileSize:(NSString *)path {
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) ) {
            return  [theFileSize intValue]/1024;
        } else {
            return -1;
        }
    } else {
        return -1;
    }
}

// 秒数格式化
- (NSString *)Timeformat2FromSeconds:(NSInteger)seconds {
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
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    }
    return format_time;
}

@end
