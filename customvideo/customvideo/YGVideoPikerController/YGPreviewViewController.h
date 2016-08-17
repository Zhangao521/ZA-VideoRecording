//
//  YGPreviewViewController.h
//  customvideo
//
//  Created by zhangkaifeng on 16/7/4.
//  Copyright © 2016年 ccyouge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
@class YGPreviewViewController;

@protocol YGPreviewViewControllerDelegate <NSObject>

-(void)YGPreviewViewController:(YGPreviewViewController *)controller didPressYesButtonWithMP4FilePath:(NSString *)path thumbImage:(UIImage *)thumbImage;

@end

@interface YGPreviewViewController : UIViewController

@property (nonatomic,strong) NSURL * videoFileURL;

@property (nonatomic,assign) id<YGPreviewViewControllerDelegate> delegate;

@end
