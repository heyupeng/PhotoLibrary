//
//  HYPFilterHelper.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPFilterHelper.h"

/// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIExposureAdjust


UIImage * CIImageToUIImage(CIImage * ciImage) {
    static CIContext * __ciContext;
    if (!__ciContext) {
        NSDictionary * options = @{kCIContextUseSoftwareRenderer : @(NO)};
        __ciContext = [[CIContext alloc] initWithOptions:options];
    }
    
    CGImageRef imageRef = [__ciContext createCGImage:ciImage fromRect:ciImage.extent];
    UIImage * image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

@implementation HYPFilterHelper

+ (NSArray *)colorEffectFilterNames {
    [CIFilter filterNamesInCategory:@""];
    NSArray * filterNames = @[
        @"CIColorCrossPolynomial",
        @"CIColorCube",
        @"CIColorCubesMixedWithMask",
        @"CIColorCubeWithColorSpace",
        @"CIColorCurves",
        @"CIColorMap",
        @"CILabDeltaE",
        @"MyHazeFilter",
        @"HYPAnonymousFacesFilter",
        @"HYPOldFilm",
        
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

+ (NSData *)cubeData:(int)size HuesFrom:(CGFloat)minHue to:(CGFloat)maxHue {
    const size_t cubeDataSize = size * size * size * 4;
    NSMutableData* cubeData = [[NSMutableData alloc] initWithCapacity:(cubeDataSize * sizeof(float))];
    
    // 2
    for (int z = 0; z < size; z++) {
        CGFloat blue = ((double)z)/(size-1);
        for (int y = 0; y < size; y++) {
            CGFloat green = ((double)y)/(size-1);
            for (int x = 0; x < size; x++) {
                CGFloat red = ((double)x)/(size-1);
                
                // 3
                CGFloat hue = [self hueFromRed:red green:green blue:blue];
                float alpha = (hue >= minHue && hue <= maxHue) ? 0 : 1;
                // 4
                float premultipliedRed = red * alpha;
                float premultipliedGreen = green * alpha;
                float premultipliedBlue = blue * alpha;
                [cubeData appendBytes:&premultipliedRed length:sizeof(float)];
                [cubeData appendBytes:&premultipliedGreen length:sizeof(float)];
                [cubeData appendBytes:&premultipliedBlue length:sizeof(float)];
                [cubeData appendBytes:&alpha length:sizeof(float)];
            }
        }
    }
    return cubeData;
}

+ (CIFilter*) chromaKeyFilterHuesFrom:(CGFloat)minHue to:(CGFloat)maxHue
{
    // 1
    const unsigned int size = 64;
    NSData * cubeData = [self cubeData:size HuesFrom:minHue to:maxHue];
    
    // 5
    CIFilter* chromaKeyFilter = [CIFilter filterWithName:@"CIColorCube"];
    [chromaKeyFilter setValue:@(size) forKey:@"inputCubeDimension"];
    [chromaKeyFilter setValue:cubeData forKey:@"inputCubeData"];
    return chromaKeyFilter;
}

+ (CGFloat) hueFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    CGFloat hue, saturation, brightness;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    return hue;
}

@end

#if !defined(MAX_XYZ)
    #define MAX_XYZ(X, Y, Z) MAX(MAX(X, Y), Z)
    #define MAX3(X, Y, Z) MAX_XYZ(X, Y, Z)
#endif

#if !defined(MIN_XYZ)
    #define MIN_XYZ(X, Y, Z) MIN(MIN(X, Y), Z)
    #define MIN3(X, Y, Z) MIN_XYZ(X, Y, Z)
#endif

/// RGB To HSV, also HSB
void RGBToHSV(float * rgb, float * hsv);

void RGBToHSV(float * rgb, float * hsv) {
    float max, min, delta;
    max = MAX3(rgb[0], rgb[1], rgb[2]);
    min = MIN3(rgb[0], rgb[1], rgb[2]);
    delta = max - min;
    
    float h = 0, s = 0, b = 0;
    if (delta != 0) {
        if (max == rgb[0]) {
            h = 60 * ((rgb[1] - rgb[2]) / delta + 0);
        }
        else if (max == rgb[1]) {
            h = 60 * ((rgb[2] - rgb[0]) / delta + 2);
        }
        else if (max == rgb[2]) {
            h = 60 * ((rgb[0] - rgb[1]) / delta + 4);
        }
    }
    if (max != 0) {
        s = delta / max;
    }
    b = max;
    
    hsv[0] = h; hsv[1] = s; hsv[2] = b;
}
