//
//  aViewController.m
//  customvideo
//
//  Created by zhangkaifeng on 16/7/4.
//  Copyright © 2016年 ccyouge. All rights reserved.
//

#import "aViewController.h"
#import "YGVideoPickerController.h"

@interface aViewController ()<YGVideoPickerControllerDelegate>
{
    UIButton *_testButton;
}
@end

@implementation aViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _testButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    _testButton.backgroundColor = [UIColor greenColor];
    [_testButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_testButton];
}

- (void)test
{
    YGVideoPickerController *controller = [[YGVideoPickerController alloc]init];
    controller.maxVideoTime = 7;
    controller.minVideoTime = 3;
    controller.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)YGVideoPickerController:(YGVideoPickerController *)controller didPressYesButtonWithMP4FilePath:(NSString *)path thumbImage:(UIImage *)thumbImage
{
    [_testButton setBackgroundImage:thumbImage forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
