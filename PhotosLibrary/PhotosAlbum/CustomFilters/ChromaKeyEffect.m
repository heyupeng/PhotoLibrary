//
//  ChromaKeyEffect.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "ChromaKeyEffect.h"

#import "HYPFilterHelper.h"

CGFloat getHueFromRGB(CGFloat r, CGFloat g, CGFloat b) {
    float rgb[3] = {(float)r, (float)g, (float)b};
    float hsv[3];
    RGBToHSV(rgb, hsv);
    return hsv[0];
}

/**
 https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_filer_recipes/ci_filter_recipes.html#//apple_ref/doc/uid/TP30001185-CH4-SW2
 
 To create a chroma key filter:
 
 - Create a cube map of data that maps the color values you want to remove so they are transparent (alpha value is 0.0).
 - Use the CIColorCube filter and the cube map to remove chroma-key color from the source image.
 - Use the CISourceOverCompositing filter to blend the processed source image over a background image
 
 要创建色度键过滤器：
 
 - 创建数据的立方体映射，映射要删除的颜色值，使其透明（alpha值为0.0）。
 - 使用CIColorCube过滤器和立方体贴图从源图像中删除色度键颜色。
 - 使用CISourceOverCompositing过滤器将处理后的源图像与背景图像混合。
 */


@interface ChromaKeyEffect ()

@end

 #import <UIKit/UIKit.h>

@implementation CIFilter (ChromaKeyEffect)

+ (CGFloat)hueFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
//    UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
//    CGFloat hue, saturation, brightness;
//    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
//    return hue;
    return getHueFromRGB(red, green, blue);
}

+ (NSData *)chromaKeyCubeDataWithDimension:(int)size HuesFrom:(CGFloat)minHue to:(CGFloat)maxHue
{
    // 1
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

@end

@implementation ChromaKeyEffect

+ (NSDictionary *)customAttributes
{
    return @{kCIAttributeFilterDisplayName: @"色值删除",
             @"inputCubeDimension" :  @{
                 kCIAttributeType      : kCIAttributeTypeCount,
                 kCIAttributeDefault   : @2,
                 kCIAttributeIdentity  : @2,
                 kCIAttributeMin       : @2,
                 kCIAttributeMax       : @64,
             },
             @"inputMinHue" : @{
                 kCIAttributeType       : kCIAttributeTypeScalar,
                 kCIAttributeDefault    : @0.1,
                 kCIAttributeIdentity   : @0.0,
                 kCIAttributeMin        : @0.0,
                 kCIAttributeMax        : @1.0,
                 kCIAttributeSliderMin  : @-0.1,
                 kCIAttributeSliderMax  : @1.1,
                 
            },
             @"inputMaxHue" : @{
                 kCIAttributeType       : kCIAttributeTypeScalar,
                 kCIAttributeDefault    : @0.3,
                 kCIAttributeIdentity   : @0.0,
                 kCIAttributeMin        : @0.0,
                 kCIAttributeMax        : @1.0,
                 kCIAttributeSliderMin  : @-0.1,
                 kCIAttributeSliderMax  : @1.1,
                },
            };
}

+ (CIFilter*)chromaKeyFilterHuesFrom:(CGFloat)minHue to:(CGFloat)maxHue
{
    const unsigned int size = 64;
    NSData * cubeData = [CIFilter chromaKeyCubeDataWithDimension:size HuesFrom:minHue to:maxHue];
    
    CIFilter* chromaKeyFilter = [CIFilter filterWithName:@"CIColorCube"];
    [chromaKeyFilter setValue:@(size) forKey:@"inputCubeDimension"];
    [chromaKeyFilter setValue:cubeData forKey:@"inputCubeData"];
    return chromaKeyFilter;
}

- (CIImage *)outputImage {
    if (!self->inputImage) {
        return self->inputBackgroundImage;
    }
    
    CIImage * outputImage;
    
    unsigned int size = 64;
    size = self->inputCubeDimension.intValue;
    if (size < 2) size = 2;
    if (size > 64) size = 64;
    
    float minHue, maxHue;
    minHue = self->inputMinHue.floatValue;
    maxHue =self->inputMaxHue.floatValue;
    NSData * cubeData;
    cubeData = [CIFilter chromaKeyCubeDataWithDimension:size HuesFrom:minHue to:maxHue];
    
    CIFilter* filter = [CIFilter filterWithName:@"CIColorCube"];
    [filter setValue:@(size) forKey:@"inputCubeDimension"];
    [filter setValue:cubeData forKey:@"inputCubeData"];
    [filter setValue:self->inputImage forKey:kCIInputImageKey];
    outputImage = filter.outputImage;
    
    if (!self->inputBackgroundImage) {
        return outputImage;
    }
    
    CIFilter* compositor = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [compositor setValue:outputImage forKey:kCIInputImageKey];
    [compositor setValue:self->inputBackgroundImage forKey:kCIInputBackgroundImageKey];
    outputImage = compositor.outputImage;
    
    return outputImage;
}

@end
