//
//  HYPFilterHelper.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPFilterHelper.h"

/// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIExposureAdjust

/**
 CICategoryBlur
 CICategoryColorAdjustment
 CICategoryColorEffect
 CICategoryCompositeOperation
 CICategoryDistortionEffect
 CICategoryGenerator
 CICategoryGeometryAdjustment
 CICategoryGradient
 CICategoryHalftoneEffect
 CICategoryReduction
 CICategorySharpen
 CICategoryStylize
 CICategoryTileEffect
 CICategoryTransition
 */

@implementation HYPFilterHelper

+ (NSArray<NSString *> *)customFilterNames {
    return @[
        @"ChromaKeyEffect",
        @"MyHazeFilter",
        @"HYPAnonymousFacesFilter",
        @"HYPOldFilm"
    ];
}

+ (NSArray *)colorEffectFilterNames {
    return [CIFilter filterNamesInCategory: kCICategoryColorEffect];
    
    NSArray * filterNames = @[
        @"CIColorCrossPolynomial",
        @"CIColorCube",
        @"CIColorCubesMixedWithMask",
        @"CIColorCubeWithColorSpace",
        @"CIColorCurves",
        @"CIColorMap",
        @"CILabDeltaE",
        
        @"CIColorMonochrome",
        @"CIColorPosterize",
        @"CIFalseColor",
        
        @"CIMaskToAlpha",
        @"CIMaximumComponent",
        @"CIMinimumComponent",
        
        @"CIPhotoEffectChrome",
        @"CIPhotoEffectTransfer",
        @"CIPhotoEffectFade",
        @"CIPhotoEffectInstant",
        @"CIPhotoEffectProcess",
        @"CIPhotoEffectMono",
        @"CIPhotoEffectNoir",
        @"CIPhotoEffectTonal",
        
        @"CISepiaTone",
        @"CIVignette",
        @"CIVignetteEffect",
        
        @"CIColorInvert",
        @"CIThermal",
        @"CIXRay"
        ];
    return filterNames;
}

+ (CIFilter
   *)chromaKeyFilterWithDimension:(NSUInteger)dimension HuesFrom:(CGFloat)minHue to:(CGFloat)maxHue {
    if (dimension < 2) dimension = 2;
    if (dimension > 64) dimension = 64;
//    uint dimension = 64;
    NSData * cubeData;
    cubeData = colorCubeTableCreateWithDimension((uint)dimension, minHue, maxHue);
    
    CIFilter* chromaKeyFilter = [CIFilter filterWithName:@"CIColorCube"];
    [chromaKeyFilter setValue:@(dimension) forKey:@"inputCubeDimension"];
    [chromaKeyFilter setValue:cubeData forKey:@"inputCubeData"];
    return chromaKeyFilter;
}

@end


/// 色彩立方体数据
/// @param dimension 维度
/// @param minHue 最小饱和度
/// @param maxHue 最大饱和度
NSData * colorCubeTableCreateWithDimension(unsigned int dimension, float minHue, float maxHue) {
    const unsigned int size = dimension;
    int cubeSize = size * size * size * 4 * sizeof(float);
    float * cubeData = malloc(cubeSize);
    float * c = cubeData;
    float rgb[3] = {0,0,0};
    float hsv[3] = {0,0,0};
    // 1
    for (int z = 0; z < size; z ++) {
        rgb[2] = (double)z / (size - 1);
        for (int y = 0; y < size; y ++) {
            rgb[1] = (double)y / (size - 1);
            for (int x = 0; x < size; x ++) {
                rgb[0] = (double)x / (size - 1);
                // 2
                RGBToHSV(rgb, hsv);
                // 3
                float alpha = (hsv[0] >= minHue && hsv[0] <= maxHue) ? 0.0 : 1.0;
                // 4
                c[0] = rgb[0] * alpha;
                c[1] = rgb[1] * alpha;
                c[2] = rgb[2] * alpha;
                c[3] = alpha;
                
                c += 4;
            }
        }
    }
    
    NSData * data = [NSData dataWithBytesNoCopy:cubeData length:cubeSize freeWhenDone:YES];
    return data;
}

UIImage * CIImageToUIImage(CIImage * ciImage) {
    static CIContext * __ciContext;
    if (!__ciContext) {
        NSDictionary * options = @{kCIContextUseSoftwareRenderer : @(NO)};
        __ciContext = [[CIContext alloc] initWithOptions:options];
    }
    
    CGImageRef imageRef = [__ciContext createCGImage:ciImage fromRect:ciImage.extent];
    CGFloat scale = UIScreen.mainScreen.scale;
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:scale orientation:0];
    CGImageRelease(imageRef);
    return image;
}
