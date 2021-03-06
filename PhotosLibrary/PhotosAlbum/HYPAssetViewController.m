//
//  HYPAssetViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPAssetViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "HYPFilterHelper.h"
#import "HYPView.h"

@interface FilterModel : NSObject

@property (nonatomic, strong) CIFilter * filter;

@end

@interface Cell : UICollectionViewCell
@property (nonatomic, readonly, strong) UIImageView * imageView;

@property (nonatomic, readonly, strong) UIImageView * iconView;
@property (nonatomic, readonly, strong) UILabel * textLabel;
@end

@implementation Cell

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    };
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.contentView.layer.masksToBounds = YES;
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.contentMode =UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    UILabel * label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:label];
    _textLabel = label;
}

- (void)layoutSubviews {
    CGRect frame = self.contentView.bounds;
    frame.size.height = frame.size.width;
    _imageView.frame = frame;
    _textLabel.frame = CGRectMake(0, CGRectGetWidth(self.contentView.frame), CGRectGetWidth(self.contentView.frame), 20);
}

@end

//@interface HYPGirdView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
//@property (nonatomic, strong) UICollectionView * collectionView;
//@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
//@property (nonatomic, strong) NSMutableArray * dataSource;
//
//- (void)reloadData:(NSMutableArray *)DataSource;
//
//@end
//
//@implementation HYPGirdView
//
//- (void)initCollectionView {
//    float spacing = 5;
//    float width = CGRectGetWidth(self.bounds) - spacing * 5;
//    width /= 4.5;
//    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    layout.minimumLineSpacing = spacing;
//    layout.minimumInteritemSpacing = spacing;
//    layout.itemSize = CGSizeMake(width, width + 20);
//    
//    _collectionView = [self configCollectView:layout];
//    [self addSubview:_collectionView];
//    [_collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"ReuseIdentifier"];
//}
//
//- (UICollectionView *)configCollectView:(UICollectionViewLayout *)layout {
//    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
//    collectionView.backgroundColor = [UIColor clearColor];
//    collectionView.dataSource = self;
//    collectionView.delegate = self;
//    return collectionView;
//}
//
//#pragma mark - CollectionView Delegate And DataSource
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.dataSource? self.dataSource.count:0;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseIdentifier" forIndexPath:indexPath];
//    
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
//#pragma mark - Setter And Getter
//
//@end

@interface HYPAssetViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    CIContext * _CIContext;
}
@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) PHLivePhotoView * livePhotoView;

@property (nonatomic, strong) AVPlayerLayer * playerLayer;

@property (nonatomic, strong) UICollectionView * collectView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) NSMutableArray * sliders;
@end

@implementation HYPAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    
    [self requestForAsset];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.hidden;
    if (self.navigationController.navigationBar.hidden) {
//        self.view.backgroundColor = [UIColor blackColor];
    } else {
//        self.view.backgroundColor = [UIColor whiteColor];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBar.hidden;
    return [super prefersStatusBarHidden];
}

- (void)setup {
//    self.view.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(topBarRightItemsAction:)];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.frame = self.view.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    _imageView = imageView;
    
    PHLivePhotoView * livePhotoView = [[PHLivePhotoView alloc] init];
    livePhotoView.frame = self.view.bounds;
    livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:livePhotoView];
    _livePhotoView = livePhotoView;
    
    [self setToolBar];
    
    [self configSliders];
}

- (void)topBarRightItemsAction:(UIBarButtonItem *)sender {
    
}

- (void)configSliders {
    _sliders = [NSMutableArray new];
    for (int i = 0; i < 3; i ++) {
        CGRect frame = CGRectMake(100, 45 + i * 35, 150, 30);
        UISlider * slider = [[UISlider alloc] initWithFrame:frame];
        [slider setMinimumValue:-1];
        [slider setMaximumValue:1];
        [slider setValue:0];
        [self.view addSubview:slider];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_sliders addObject:slider];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSInteger index = [_sliders indexOfObject:slider];
    float value = slider.value;
    NSLog(@"slider%ld value:%.2f", index, value);
    NSIndexPath * indexPath = [self.collectView indexPathsForSelectedItems][0];
    
    NSString * filterName = [self.dataSource objectAtIndex:indexPath.row];
    if (index == 0) {
        
    }
    CIImage *output = [self imageByFilter:filterName withImage:self.model.originImage];
    self.imageView.image = CIImageToUIImage(output);
}

- (void)setToolBar {
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 44, CGRectGetWidth(self.view.bounds), 44);
    view.backgroundColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:0.7];

    [self.view addSubview:view];
    
    NSArray * items = @[@"ColorEffect", @"Stylize", @"Adjustment"];
    NSMutableArray * btns = [NSMutableArray new];
    for (int i = 0; i < items.count; i ++) {
        NSString * item = [items objectAtIndex:i];
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20 + i * 70, 2, 60, 40);
        btn.tag = i + 1024;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn addTarget:self action:@selector(toolbarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [btns addObject:btn];
        [view addSubview:btn];
        [btn setTitle:item forState:UIControlStateNormal];
    }
}

- (void)toolbarBtnClick:(UIButton *)sender {
    NSInteger index = sender.tag - 1024;
    NSLog(@"Tool bar index:%ld", index);
    if (index == 0) {
        [self filterListForColorEffect];
    } else if (index == 1){
        [self filterListForStylize];
    } else {
        [self filterListForColorAdjustment];
    }
}

- (void)initCollectionView {
    float spacing = 5;
    float width = CGRectGetWidth(self.view.bounds) - spacing * 5;
    width /= 4.5;
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = spacing;
    layout.minimumInteritemSpacing = spacing;
    layout.itemSize = CGSizeMake(width, width + 20);
    
    width = width + 30 + spacing * 2;
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - width - 44, CGRectGetWidth(self.view.bounds), width);
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"ReuseIdentifier"];
    [self.view addSubview:collectionView];
    _collectView = collectionView;
}

- (void)showEffectBrowser {
    if (_collectView) {
        return;
    }
    [self filterListForColorEffect];
}

- (void)requestForAsset {
    if (_model.asset.mediaType == PHAssetMediaTypeVideo) {
        [self updateVideo];
    } else {
        [self updateImage];
    }
}

- (void)updateImage {
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.imageView.bounds;
    maskLayer.backgroundColor = [[[UIColor blackColor]colorWithAlphaComponent:0.5] CGColor];
    maskLayer.fillColor = [[[UIColor whiteColor]colorWithAlphaComponent:1] CGColor];
    maskLayer.strokeColor = [[UIColor greenColor] CGColor];
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(10, 100, 300, 300)];
    maskLayer.path = path.CGPath;
    [self.imageView.layer setMask: maskLayer];
    
    HYPCropView * crop = [[HYPCropView alloc] init];
    crop.frame = CGRectMake(10, 100, 300, 300);//self.imageView.bounds;
    [self.view addSubview:crop];
//    [self.imageView.layer setMask: crop.layer];

    if (_model.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        [self updatePhotoLive];
    } else {
        if (self.model.originImage) {
            self.livePhotoView.hidden = YES;
            self.imageView.hidden = NO;
            self.imageView.image = self.model.originImage;
            [self autoAdjustmentFilters];
            return;
        }
        [self updateStaticImageCompletion:^(UIImage *image, NSDictionary *info) {
            self.livePhotoView.hidden = YES;
            self.imageView.hidden = NO;
            self.imageView.image = image;
            [self autoAdjustmentFilters];
        }];
    }
    
    PHContentEditingInputRequestOptions * options = [[PHContentEditingInputRequestOptions alloc] init];
    
    [_model.asset requestContentEditingInputWithOptions: options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        if (!contentEditingInput) {
            return ;
        }
        NSLog(@"ImageURL:%@", contentEditingInput.fullSizeImageURL);
    }];
}

- (void)updateStaticImageCompletion:(void(^)(UIImage * image, NSDictionary * info))completion {
    CGSize size = CGSizeMake(_model.asset.pixelWidth, _model.asset.pixelHeight);
    
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    /*
     PHImageRequestOptionsDeliveryModeHighQualityFormat //client将只获得一个结果 asynchronous
     PHImageRequestOptionsDeliveryModeFastFormat //  synchronous
     */
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = true;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        if (error) {
            NSLog(@"%@",error.domain);
        }
    };
    
    [self requestImageForAsset:_model.asset targetSize:size options:options compeletion:^(UIImage *image, NSDictionary *info) {
        if (image && completion) {
            completion(image, info);
        }
        if ([info objectForKey:PHImageErrorKey]) {
            [self requestImageDataForAsset:self.model.asset completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {

            }];
        }
    }];
}

- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)size options:(PHImageRequestOptions *)options compeletion:(void(^)(UIImage * image, NSDictionary * info))compeletion {
    
    PHImageRequestID requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (compeletion) {
            compeletion(result, info);
        }
    }];
    return requestID;
}

- (void)requestImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion {
    
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    // PHImageRequestOptionsDeliveryModeHighQualityFormat //client将只获得一个结果
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = true;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        if (error) {
            NSLog(@"%@",error.domain);
        }
    };
    [self requestImageDataForAsset:asset options:options completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (completion) {
            completion(imageData, dataUTI, orientation, info);
        }
    }];
}
- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset options:(PHImageRequestOptions *)options completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion {
    
    PHImageRequestID requestID = [[PHCachingImageManager alloc] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) {
            completion(imageData, dataUTI, orientation, info);
        }
    }];
    return requestID;
}

- (void)updatePhotoLive {
    CGSize size = CGSizeMake(_model.asset.pixelWidth, _model.asset.pixelHeight);
    PHLivePhotoRequestOptions * options = [[PHLivePhotoRequestOptions alloc] init];
    options.networkAccessAllowed = true;

    [[PHCachingImageManager defaultManager]requestLivePhotoForAsset:_model.asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        self.imageView.hidden = YES;
        self.livePhotoView.hidden = NO;
        self.livePhotoView.livePhoto = livePhoto;
        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
    }];
}

- (void)updateVideo {
    [self requestVideoCompletion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (!playerItem) {
            return ;
        }
        AVPlayerLayer * playerLayer = [[AVPlayerLayer alloc] init];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        playerLayer.frame = self.view.layer.bounds;
        
        playerLayer.player = [AVPlayer playerWithPlayerItem:playerItem];
        [self.view.layer addSublayer:playerLayer];
        self.playerLayer = playerLayer;
//        [self.playerLayer.player play];
    }];
}

- (void)requestVideoCompletion:(void(^)(AVPlayerItem * playerItem, NSDictionary * info))completion {
    PHAsset * asset = _model.asset;
    PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = true;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        NSLog(@"Video progress: %.2f", progress);
    };
    
    [[PHCachingImageManager defaultManager]requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) {
            completion(playerItem, info);
        }
    }];
}

- (void)autoAdjustmentFilters {
    UIImage * originImage = self.model.originImage;
    CIImage * inputImage = [[CIImage alloc] initWithImage:originImage];
    NSArray * array = [inputImage autoAdjustmentFilters];
    
    for (CIFilter * filter in array) {
        [filter setValue:inputImage forKey:kCIInputImageKey];
        CIImage * outputImage = filter.outputImage;
        if (outputImage) {
            inputImage = [outputImage copy];
        }
    }
    
    UIImageView * iv = [[UIImageView alloc] init];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.frame = CGRectMake(0 * 90, 100, 80, 80);
    [self.view addSubview:iv];
    iv.image = [UIImage imageWithCIImage:inputImage];

}

- (void)filterListForStylize {
    NSArray * filterNames;
    filterNames = [CIFilter filterNamesInCategory: kCICategoryStylize];
    
    [self filterEffectBrowser:filterNames];
}

- (void)filterListForColorEffect {
    NSArray * filterNames;
    filterNames = [HYPFilterHelper colorEffectFilterNames];
//    NSLog(@"filterNames: %@", filterNames);
    
    [self filterEffectBrowser:filterNames];
}

- (void)filterListForColorAdjustment {
    NSArray * filterNames;
    filterNames = [CIFilter filterNamesInCategory: kCICategoryColorAdjustment];
    
    filterNames = @[ @"CIColorClamp",
       @"CIColorControls",
       @"CIColorMatrix",
       @"CIColorPolynomial",
       @"CIExposureAdjust",
       @"CIGammaAdjust",
       @"CIHueAdjust",
       @"CILinearToSRGBToneCurve",
       @"CISRGBToneCurveToLinear",
       @"CITemperatureAndTint",
       @"CIToneCurve",
       @"CIVibrance",
       @"CIWhitePointAdjust"];
    [self filterEffectBrowser:filterNames];
}


- (CIImage *)imageByFilter:(NSString *)filterName withCIImage:(CIImage *)ciImage {
    CIFilter * filter = [CIFilter filterWithName:filterName];
    if (!filter) {
        NSLog(@"无法创建%@过滤器", filterName);
        return ciImage;
    }
    NSLog(@"%@: %@", filterName, [filter attributes]);
    [filter setDefaults];
    
    NSArray * inputKeys = [filter inputKeys];
    if ([inputKeys containsObject:kCIInputImageKey]) {
        [filter setValue: ciImage forKey:kCIInputImageKey];
    }
    if([inputKeys containsObject:kCIInputCenterKey]){
        // parameters for CIVignetteEffect
        CGSize size = ciImage.extent.size;
        CGFloat R = MIN(size.width, size.height) * 0.5;
        CIVector *vct = [[CIVector alloc] initWithX:R Y:R];
        [filter setValue:vct forKey:@"inputCenter"];
        [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
        [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    }
    
    
    CIImage * outputImage = [filter outputImage];
    return outputImage;
}

- (CIImage *)imageByFilter:(NSString *)filterName withImage:(UIImage *)image {
    CIFilter * filter = [CIFilter filterWithName:filterName];
    CIImage * ciImage =  [[CIImage alloc] initWithImage:image];
    if (!filter) {
        NSLog(@"无法创建%@过滤器", filterName);
        return ciImage;
    }
    
    NSArray * inputKeys = [filter inputKeys];
    if ([inputKeys containsObject:kCIInputImageKey]) {
        [filter setValue: ciImage forKey:kCIInputImageKey];
    }
    [filter setDefaults];
    
    if([inputKeys containsObject:kCIInputCenterKey]){
        // parameters for CIVignetteEffect
//        CGSize size = image.size;
//        CIVector *vct = [[CIVector alloc] initWithX:size.width * image.scale/2 Y:size.height * image.scale/2];
//        [filter setValue:vct forKey:kCIInputCenterKey];
    }
    
    if ([filterName isEqualToString:@"CIColorCube"]) {
        filter = [HYPFilterHelper chromaKeyFilterWithDimension:64 HuesFrom:210/360.0 to:240/360.0];
        [filter setValue:ciImage forKey:kCIInputImageKey];
    }
    if([filterName isEqualToString:@"CIVignetteEffect"]){
        CGSize size = image.size;
        CIVector *vct = [[CIVector alloc] initWithX:size.width * image.scale/2 Y:size.height * image.scale/2];
        [filter setValue:vct forKey:kCIInputCenterKey];
        
        CGFloat R = MIN(size.width, size.height) * image.scale * 0.375;
        [filter setValue:[NSNumber numberWithFloat:R] forKey:kCIInputRadiusKey];
        
        [filter setValue:[NSNumber numberWithFloat:0.95] forKey:kCIInputIntensityKey];
    }
    
    if ([filterName isEqualToString:@"CIEdges"]) {
        [filter setValue:[NSNumber numberWithFloat:5] forKey:kCIInputIntensityKey];

    }
    
    [self ColorEffectFilter:filter];
    
    [self ColorAdjustmentFilterSetDefault:filter];
    
    CIImage * outputImage = [filter outputImage];
    return outputImage;
}

- (void)ColorEffectFilter:(CIFilter *)filter {
    NSString * filterName = filter.name;
    
    if ([filterName isEqualToString:@"CIColorMonochrome"]) {
        float levels = 0.5 + [(UISlider *)[_sliders objectAtIndex:0] value] * 0.5;
        [filter setValue:[NSNumber numberWithFloat:levels] forKey:@"inputIntensity"];
    }
    
    if ([filterName isEqualToString:@"CIColorPosterize"]) {
        float levels = 15 + [(UISlider *)[_sliders objectAtIndex:0] value] * 10;
        [filter setValue:[NSNumber numberWithFloat:levels] forKey:@"inputLevels"];
    }
    
    if ([filterName isEqualToString:@"CIFalseColor"]) {
        CIColor * color0 = [CIColor colorWithRed:0.2 green:0 blue:0 alpha:1];
        [filter setValue:color0 forKey:@"inputColor0"];
    }
    
    if([filterName isEqualToString:@"CISepiaTone"]){
        [filter setValue:[NSNumber numberWithFloat:0.5] forKey:kCIInputIntensityKey];
    }
}

- (void)ColorAdjustmentFilterSetDefault:(CIFilter *)filter {
    NSString * filterName = filter.name;
    // ColorAdjustment
    if ([filterName isEqualToString:@"CIColorClamp"]) {
        CIVector *maxVct = [[CIVector alloc] initWithX:0.75 Y:0.75 Z:0.75 W:0.75];
        CIVector *minVct = [[CIVector alloc] initWithX:0.25 Y:0.25 Z:0.25 W:0.25];
        [filter setValue:maxVct forKey:@"inputMaxComponents"];
//        [filter setValue:minVct forKey:@"inputMinComponents"];
    }
    
    if ([filterName isEqualToString:@"CIColorControls"]) {
        // Saturation 0 - 2
        UISlider * slider = (UISlider *)[_sliders objectAtIndex:0];
        float saturation = (slider.value - slider.minimumValue)/(slider.maximumValue - slider.minimumValue) * (2.0 - 0.);
        [filter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
        
        // Brightness -1 - 1
        slider = (UISlider *)[_sliders objectAtIndex:1];
        float brightness = 0 + (slider.value)/(slider.maximumValue - slider.minimumValue) * (0.25);
        [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
        
        // Contrast 0.25 - 4
        slider = (UISlider *)[_sliders objectAtIndex:2];
        float contrast = 1.0 + (slider.value)/(slider.maximumValue - slider.minimumValue) * (1.25 - 0.) * 0.3;
        [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputContrast"];
        NSLog(@"%.2f, %.2f, %.2f", saturation, brightness, contrast);
    }
    
    if ([filterName isEqualToString:@"CIColorMatrix"]) {
        NSDictionary * params = @{
          @"inputRVector": [CIVector vectorWithX:-1 Y:0 Z:0],
          @"inputGVector": [CIVector vectorWithX:0 Y:-1 Z:0],
          @"inputBVector": [CIVector vectorWithX:0 Y:0 Z:-1],
          @"inputBiasVector": [CIVector vectorWithX:0.75 Y:0.75 Z:0.75]
                                  };
        for (NSString * key in params.allKeys) {
            [filter setValue:[params objectForKey:key] forKey:key];
        }
    }
    
    if([filterName isEqualToString:@"CIColorPolynomial"]){
        NSDictionary * params = @{
          @"inputRedCoefficients": [CIVector vectorWithX:0 Y:0 Z:0.2 W:0.4],
          @"inputGreenCoefficients": [CIVector vectorWithX:0 Y:0 Z:0.2 W:.8],
          @"inputBlueCoefficients": [CIVector vectorWithX:0 Y:0 Z:0.5 W:1],
          @"inputAlphaCoefficients": [CIVector vectorWithX:0 Y:1 Z:1 W:1]
                                  };
        for (NSString * key in params.allKeys) {
            [filter setValue:[params objectForKey:key] forKey:key];
        }
    }
    
    // 曝光
    if([filterName isEqualToString:@"CIExposureAdjust"]){
        UISlider * slider = (UISlider *)[_sliders objectAtIndex:1];
        float exposure = 0.0 + slider.value * 2;
        [filter setValue:[NSNumber numberWithFloat:exposure] forKey:@"inputEV"];
    }
    
    if([filterName isEqualToString:@"CIGammaAdjust"]){
        UISlider * slider = (UISlider *)[_sliders objectAtIndex:2];
        float gamma = 1.0 + slider.value * 0.5;
        gamma = powf(gamma, 2);
        [filter setValue:[NSNumber numberWithFloat:gamma] forKey:@"inputPower"];
    }
}

- (void)filterEffectBrowser:(NSArray <NSString *> *)filterNames {
    if (!filterNames || filterNames.count == 0) {
        return;
    }
    if (!_collectView) {
        [self initCollectionView];
    }
    
    self.dataSource = [NSMutableArray new];
    [self.dataSource addObjectsFromArray:filterNames];
    [self.collectView reloadData];
}

- (void)filter: (NSString *)filterName {
    // Used to identify the format of the data blob (e.g. identifier "com.apple.myapp" and version "1.0")
    NSString * formatIndentify = [[NSBundle mainBundle] bundleIdentifier];
    NSString * formatVersion = [[NSBundle mainBundle] bundleIdentifier];
    NSData * data = [filterName dataUsingEncoding:NSUTF8StringEncoding];
    
    PHAdjustmentData * adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:formatIndentify formatVersion:formatVersion data:data];
    
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource? self.dataSource.count:0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Cell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseIdentifier" forIndexPath:indexPath];

    NSString * filterName = [self.dataSource objectAtIndex:indexPath.row];
    
    CIImage *output = [self imageByFilter:filterName withImage:self.model.postImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage * image = CIImageToUIImage(output);
        cell.imageView.image = image;
    });

    NSString * text = filterName;
    NSString * subString = @"CIColor";
    NSRange range = [text rangeOfString:subString];
    if ([text hasPrefix:subString]) {
        text = [text substringFromIndex:range.location + range.length];
    }
    subString = @"CIPhoto";
    range = [text rangeOfString:subString];
    if ([text hasPrefix:subString]) {
        text = [text substringFromIndex:range.location + range.length];
    }
    
    cell.textLabel.text = text;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * filterName = [self.dataSource objectAtIndex:indexPath.row];

    CIImage *output = [self imageByFilter:filterName withImage:self.model.originImage];//[filter outputImage];
    
    self.imageView.image = CIImageToUIImage(output);
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
