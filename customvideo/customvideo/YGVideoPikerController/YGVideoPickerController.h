//
//  ViewController.h
//  customvideo
//
//  Created by zhangkaifeng on 16/7/2.
//  Copyright © 2016年 ccyouge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class YGVideoPickerController;

@protocol YGVideoPickerControllerDelegate <NSObject>

-(void)YGVideoPickerController:(YGVideoPickerController *)controller didPressYesButtonWithMP4FilePath:(NSString *)path thumbImage:(UIImage *)thumbImage;

@end

@interface YGVideoPickerController : UIViewController

//最大视频长度
@property (nonatomic,assign) float maxVideoTime;
//最小视频长度
@property (nonatomic,assign) float minVideoTime;

@property (nonatomic,assign) id<YGVideoPickerControllerDelegate> delegate;



@end

