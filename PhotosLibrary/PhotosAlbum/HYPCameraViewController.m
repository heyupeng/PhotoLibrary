//
//  HYPCameraViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2019/5/23.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import "HYPCameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface HYPCameraViewController ()

@property (nonatomic, strong) UIImagePickerController * imagePickerController;

@end

@implementation HYPCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImagePickerController *)createImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
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
