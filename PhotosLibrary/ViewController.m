//
//  ViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/23.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "ViewController.h"
#import "PhotosAlbum/HYPAlbumViewController.h"
#import "PhotosAlbum/HYPCameraViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)photoClick:(UIButton *)sender {
    HYPAlbumViewController * avc = [[HYPAlbumViewController alloc] init];
    avc.completion = ^(BOOL isSuccess, NSArray * _Nonnull items) {
        if (!isSuccess) {
            NSLog(@"取消选择");
        }
    };
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:avc];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (IBAction)imagePickerAction:(UIButton *)sender {
    UIImagePickerController * imagePicker = [self createImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerController
- (UIImagePickerController *)createImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType ;//UIImagePickerControllerSourceTypePhotoLibrary;
    if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePicker.cameraDevice =  UIImagePickerControllerCameraDeviceRear;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    
    return imagePicker;
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // 拍照
        if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
            UIImage * image;
            if (picker.allowsEditing) {
                image = [info objectForKey:UIImagePickerControllerEditedImage];
            } else {
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            // 保存图片
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        // 录制视频
        else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) {
            NSURL * videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSString * videoPath = [videoURL absoluteString];
            // 保存视频
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"ImagePickerController did cancel");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController API completion selector about saving to SavedPhotosAlbum
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存图片失败");
    } else {
        NSLog(@"保存图片成功");
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存图片失败");
    } else {
        NSLog(@"保存图片成功");
    }
}

@end
