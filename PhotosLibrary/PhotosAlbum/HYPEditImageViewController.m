//
//  HYPEditImageViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2019/1/3.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import "HYPEditImageViewController.h"
#import <PhotosUI/PhotosUI.h>

#import "HYPFilterHelper.h"
#import "HYPView.h"

#import "FilterAttributesController.h"

@interface HYPCell : UICollectionViewCell
@property (nonatomic, readonly, strong) UIImageView * imageView;

@property (nonatomic, readonly, strong) UIImageView * iconView;
@property (nonatomic, readonly, strong) UILabel * textLabel;
@end

@implementation HYPCell

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


@interface HYPEditImageViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) PHLivePhotoView * livePhotoView;

@property (nonatomic, strong) UICollectionView * collectView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) HYPCropView * cropView;

@property (nonatomic, strong) UIImage * inputImage;
@property (nonatomic, strong) UIImage * outputImage;

@end

@implementation HYPEditImageViewController

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
    return YES;
    return [super prefersStatusBarHidden];
}

- (void)setup {
    self.view.backgroundColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1];
    
    if (self.navigationController.childViewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(topBarLeftItemsAction:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(topBarRightItemsAction:)];
    
    UIView * view = [[UIView alloc] init];
    view.frame = self.view.bounds;
    [self.view addSubview:view];
    
    // scrollView
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.frame = view.bounds;
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.contentSize = scrollView.frame.size;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.clipsToBounds = NO;
    [view addSubview:scrollView];
    _scrollView = scrollView;
    
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // imageView
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    imageView.frame = self.view.bounds;
    [_scrollView addSubview:imageView];
    _imageView = imageView;
    
    PHLivePhotoView * livePhotoView = [[PHLivePhotoView alloc] init];
    livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    livePhotoView.frame = self.view.bounds;
    [self.view addSubview:livePhotoView];
    _livePhotoView = livePhotoView;
    
    [self setToolBar];
    
}

- (void)topBarLeftItemsAction:(UIBarButtonItem *)sender {
    if (self.navigationController) {
        if (self.navigationController.childViewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (self.parentViewController.navigationController) {
            [self.parentViewController.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)topBarRightItemsAction:(UIBarButtonItem *)sender {
    
}

- (CGRect)toolBarRectWithBounds:(CGRect)bounds {
    UIEdgeInsets safeAreaInsets;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
    } else {
//         Fallback on earlier versions
    }
    CGFloat toolBarHeight = 44 + safeAreaInsets.bottom;
    
    CGRect frame = bounds;
    frame.origin.y = CGRectGetHeight(frame) - toolBarHeight;
    frame.size.height = toolBarHeight;
    return frame;
}

- (void)setToolBar {
    
    CGRect frame = [self toolBarRectWithBounds:self.view.bounds];
    
    // 1
    UIView * toolBar = [[UIView alloc] init];
    toolBar.frame = frame;
    toolBar.backgroundColor = [[UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1.0] colorWithAlphaComponent:0.85];
    [self.view addSubview:toolBar];
    // 2
    UIView * toolBarContentViw = [[UIView alloc] init];
    toolBarContentViw.frame = CGRectMake(0, 0, CGRectGetWidth(frame), 44);
    [toolBar addSubview:toolBarContentViw];
    // 3
    NSArray * items = @[@"ColorEffect", @"Stylize", @"Adjustment", @"Transition", @"HalftoneEffect"];
    NSMutableArray * btns = [NSMutableArray new];
    CGFloat left = 5;
    for (int i = 0; i < items.count; i ++) {
        NSString * item = [items objectAtIndex:i];
        
        NSDictionary * atts= @{
            NSFontAttributeName:[UIFont systemFontOfSize:12],
        };
        CGRect textRect = [item boundingRectWithSize:CGSizeMake(200, 44) options:0 attributes:atts context:nil];
        textRect = CGRectMake(left, 0, CGRectGetWidth(textRect) + 20, 44);
        left += CGRectGetWidth(textRect);
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = textRect;
        btn.tag = i + 1024;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [btn setTitle:item forState:UIControlStateNormal];
        [btn.titleLabel adjustsFontSizeToFitWidth];
        [btn addTarget:self action:@selector(toolbarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [btns addObject:btn];
        [toolBarContentViw addSubview:btn];
    }
}

- (void)toolbarBtnClick:(UIButton *)sender {
    NSInteger index = sender.tag - 1024;
    NSLog(@"Tool bar index:%ld", index);
    if (index == 0) {
        [self filterListForColorEffect];
    } else if (index == 1){
        [self filterListForStylize];
    } else if (index == 2){
        [self filterListForColorAdjustment];
    } else if (index == 3) {
        NSArray * names = [CIFilter filterNamesInCategory:kCICategoryTransition];
        [self filterEffectBrowser:names];
    } else if (index == 4) {
        NSArray * names = [CIFilter filterNamesInCategory:kCICategoryHalftoneEffect];
        [self filterEffectBrowser:names];
    } else {
            
//        self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.hidden;
//        if (self.navigationController.navigationBar.hidden) {
//            [self corp];
//        }
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
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), width);
    frame.origin.y = [self toolBarRectWithBounds:self.view.bounds].origin.y - width;
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[HYPCell class] forCellWithReuseIdentifier:@"ReuseIdentifier"];
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
    if (_model.asset.mediaType == PHAssetMediaTypeImage) {
        [self updateImage];
    }
    else  if (!_model) {
        UIImage * image = [UIImage imageNamed:@"inputImage2"];
        self.livePhotoView.hidden = YES;
        self.imageView.hidden = NO;
        self.inputImage = image;
        [self autoAdjustmentFilters];
    }
}

- (CGSize)imageViewSizeWithContentSize:(CGSize)contentSize ImageSize:(CGSize)imageSize {
    if (imageSize.height == 0 || contentSize.height == 0) {return CGSizeZero;
    }
    
    float imageRatio = imageSize.width/imageSize.height;
    if (contentSize.width / contentSize.height < imageRatio) {
        contentSize.height = contentSize.width / imageRatio;
    } else {
        contentSize.width = contentSize.height * imageRatio;
    }
    return contentSize;
}

- (void)setInputImage:(UIImage *)inputImage {
    _inputImage = inputImage;
    self.imageView.image = inputImage;
    CGSize size = [self imageViewSizeWithContentSize:self.scrollView.bounds.size ImageSize:inputImage.size];
    CGPoint center = self.imageView.center;
    CGRect frame = self.imageView.frame;
    frame.size = size;
    self.imageView.frame = frame;;
    self.imageView.center = center;
}

- (void)refreshImageViewCenter {
    CGPoint center = CGRectGetInnerCenterPoint(_scrollView.bounds);
    if (_scrollView.contentSize.width > CGRectGetWidth(_scrollView.frame)) {
        center.x = _scrollView.contentSize.width * 0.5;
    }
    if (_scrollView.contentSize.height >CGRectGetHeight(_scrollView.frame)) {
        center.y = _scrollView.contentSize.height * 0.5;
    }
    _imageView.center = center;
}

- (void)updateImage {
    if (_model.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        [self updatePhotoLive];
    } else {
        if (self.model.originImage) {
            self.livePhotoView.hidden = YES;
            self.imageView.hidden = NO;
            self.inputImage = self.model.originImage;
            [self autoAdjustmentFilters];
            return;
        }
        [self updateStaticImageCompletion:^(UIImage *image, NSDictionary *info) {
            self.livePhotoView.hidden = YES;
            self.imageView.hidden = NO;
            self.inputImage = image;
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
    
//    filterNames = @[
//        @"CIColorAbsoluteDifference",
//        @"CIColorClamp",
//        @"CIColorControls",
//        @"CIColorMatrix",
//        @"CIColorPolynomial",
//        @"CIColorThreshold",
//        @"CIColorThresholdOtsu",
//        @"CIDepthToDisparity",
//        @"CIDisparityToDepth",
//        @"CIExposureAdjust",
//        @"CIGammaAdjust",
//        @"CIHueAdjust",
//        @"CILinearToSRGBToneCurve",
//        @"CISRGBToneCurveToLinear",
//        @"CITemperatureAndTint",
//        @"CIToneCurve",
//        @"CIVibrance",
//        @"CIWhitePointAdjust"
//    ];
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

- (CIFilter *)defaultFilter:(NSString *)filterName withImage:(UIImage *)image {
    CIFilter * filter = [CIFilter filterWithName:filterName];
    CIImage * ciImage =  [[CIImage alloc] initWithImage:image];
    if (!filter) {
        NSLog(@"无法创建%@过滤器", filterName);
        return nil;
    }
    
    NSArray * inputKeys = [filter inputKeys];
    if ([inputKeys containsObject:kCIInputImageKey]) {
        if (!ciImage) {
            UIImage * image2 = [UIImage imageNamed:@"inputImage2"];
            ciImage = [[CIImage alloc] initWithImage:image2];
        }
        [filter setValue: ciImage forKey:kCIInputImageKey];
    }
    NSString * inputImageKey = @"inputImage2";
    if ([inputKeys containsObject:inputImageKey]) {
        UIImage * image2 = [UIImage imageNamed:@"inputImage2"];
        [filter setValue:[[CIImage alloc] initWithImage:image2] forKey:inputImageKey];
    }
    inputImageKey = @"inputTargetImage";
    if ([inputKeys containsObject:inputImageKey]) {
        UIImage * image2 = [UIImage imageNamed:@"inputImage3"];
        [filter setValue:[[CIImage alloc] initWithImage:image2] forKey:inputImageKey];
    }
    inputImageKey = @"inputBackgroundImage";
    if ([inputKeys containsObject:inputImageKey]) {
        UIImage * image2 = [UIImage imageNamed:@"inputImage3"];
        [filter setValue:[[CIImage alloc] initWithImage:image2] forKey:inputImageKey];
    }
    inputImageKey = @"inputGradientImage";
    if ([inputKeys containsObject:inputImageKey]) {
        UIImage * image2 = [UIImage imageNamed:@"inputImage3"];
        [filter setValue:[[CIImage alloc] initWithImage:image2] forKey:inputImageKey];
    }
    
    inputImageKey = @"inputMaskImage";
    if ([inputKeys containsObject:inputImageKey]) {
        UIImage * image2 = [UIImage imageNamed:@"maskImage"];
        [filter setValue:[[CIImage alloc] initWithImage:image2] forKey:inputImageKey];
    }
    [filter setDefaults];
    
    if ([filterName isEqualToString:@"CIColorCube"]) {
        filter = [HYPFilterHelper chromaKeyFilterHuesFrom:210/360.0 to:240/360.0];
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
    
    return filter;
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
    
    if ([filterName isEqualToString:@"CIColorCube"]) {
        filter = [HYPFilterHelper chromaKeyFilterHuesFrom:210/360.0 to:240/360.0];
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
        float levels = 0.5;
        [filter setValue:[NSNumber numberWithFloat:levels] forKey:@"inputIntensity"];
    }
    
    if ([filterName isEqualToString:@"CIColorPosterize"]) {
        float levels = 15;
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

float lerp_map(float value, float minimum, float maximum, float lowwerBounds, float upperBounds) {
    float t = (value - minimum)/(maximum - minimum);
    return lowwerBounds * (1 - t) + upperBounds * t;
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
        float saturation = lerp_map(0, -1, 1, 0, 2);
        [filter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
        
        // Brightness -1 - 1
        float brightness = lerp_map(0, -1, 1, -1, 1);
        [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
        
        // Contrast 0.25 - 4
        float contrast = lerp_map(0.5, -1, 1, 0, 4);
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
        float exposure = 0.0;
        [filter setValue:[NSNumber numberWithFloat:exposure] forKey:@"inputEV"];
    }
    
    if([filterName isEqualToString:@"CIGammaAdjust"]){
        float gamma = 1.0;
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

- (void)corp {
    float scale = 0.8;
    CGSize size = CGSizeFromScale(self.imageView.bounds.size, scale);
    self.scrollView.zoomScale = 1.0;
//    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
//    self.scrollView.contentSize = self.scrollView.frame.size;
//    self.scrollView.center = CGRectGetInnerCenterPoint(self.scrollView.superview.bounds);
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.center = CGRectGetInnerCenterPoint(self.scrollView.frame);
    [self refreshImageViewCenter];
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.scrollView.superview.bounds;
    maskLayer.backgroundColor = [[[UIColor blackColor]colorWithAlphaComponent:0.5] CGColor];
    maskLayer.fillColor = [[[UIColor whiteColor]colorWithAlphaComponent:1] CGColor];
    maskLayer.strokeColor = [[UIColor greenColor] CGColor];
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:[self.scrollView convertRect:self.imageView.frame toView:self.scrollView.superview]];
    maskLayer.path = path.CGPath;
    [self.scrollView.superview.layer setMask: maskLayer];
    
    HYPCropView * crop = [[HYPCropView alloc] init];
    crop.frame = [self.view convertRect:self.imageView.frame fromView:self.scrollView];
    crop.refreshPropertyCallback = ^(UIView * _Nonnull view, NSString * _Nonnull key) {
        CGRect rect = view.frame;
        rect = [self.scrollView.superview convertRect:view.frame fromView:self.view];
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
        [(CAShapeLayer *)self.scrollView.superview.layer.mask setPath:path.CGPath];
        [self refreshScrollViewContentInset];
    };
    [self.view addSubview:crop];
    _cropView = crop;
}

- (void)refreshScrollViewContentInset {
    CGRect frame = [self.view convertRect:self.cropView.frame toView:self.scrollView.superview];
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return;
    }
    CGPoint minPoint = CGRectGetMinPoint(frame);
    CGPoint maxPoint = CGRectGetMaxPoint(frame);
    CGPoint minDistance = CGPointSubtractPoint(minPoint, CGRectGetMinPoint(self.scrollView.frame));
    CGPoint maxDistance = CGPointSubtractPoint(CGRectGetMaxPoint(self.scrollView.frame), maxPoint);
    self.scrollView.contentInset = UIEdgeInsetsMake(minDistance.y, minDistance.x, maxDistance.y, maxDistance.x);
    
}
#pragma mark - ScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        return scrollView.subviews[0];
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshScrollViewContentInset];

    [self refreshImageViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentInset];
    
    [self refreshImageViewCenter];
}


#pragma mark - CollectionView delegate and dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource? self.dataSource.count:0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HYPCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseIdentifier" forIndexPath:indexPath];
    
    NSString * filterName = [self.dataSource objectAtIndex:indexPath.row];
    
    CIImage *output = [self defaultFilter:filterName withImage:self.model.image].outputImage;// [self imageByFilter:filterName withImage:self.model.image];
    
    cell.imageView.image = nil;
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

- (void)updateImageWithFilter:(CIFilter *)filter {
    CIImage * outputImage = filter.outputImage;
    UIImage * image;
//    image = [UIImage imageWithCIImage:outputImage];
    image = CIImageToUIImage(outputImage);
    self.imageView.image = image;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * filterName = [self.dataSource objectAtIndex:indexPath.row];
    
//    CIImage *output = [self imageByFilter:filterName withImage:self.model.originImage];
//    self.imageView.image = CIImageToUIImage(output);
    
    CIFilter * filter;
//    filter = [CIFilter filterWithName:filterName];
//    [filter setValue:[[CIImage alloc] initWithImage:self.model.originImage] forKey:kCIInputImageKey];
//    [filter setDefaults];
    filter = [self defaultFilter:filterName withImage:self.model.originImage];
    self.imageView.image = CIImageToUIImage([filter outputImage]);
    
    FilterAttributesController * vc = [[FilterAttributesController alloc] init];
    vc.filter = filter;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    weakly(self);
    vc.FilterAttributesValueChangedBlock = ^(CIFilter * _Nonnull filter, NSDictionary * _Nonnull att) {
        if (weakself) {
//            NSLog(@"%@", filter);
            [weakself updateImageWithFilter:filter];
        }
    };
    
    [self presentViewController:vc animated:YES completion:nil];
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
