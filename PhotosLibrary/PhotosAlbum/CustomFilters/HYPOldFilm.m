//
//  HYPOldFilm.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPOldFilm.h"

@interface HYPOldFilm ()

@end

/**
 https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_filer_recipes/ci_filter_recipes.html#//apple_ref/doc/uid/TP30001185-CH4-SW1

 模拟粗糙的模拟胶片
 降低图像质量，使其看起来像过时的、粗糙的模拟胶片。

 CISepiaTone棕褐色滤镜将图像的色调更改为类似于旧模拟照片的红褐色。可以通过应用随机斑点和划痕来增强效果。
 过滤后的白噪声与深色划痕结合到Piatone滤光片上，以创建旧的模拟胶片效果
 
 以下步骤利用内置核心图像过滤器对图像进行着色和纹理处理，使其看起来像是模拟胶片：
 应用 CISepiaTone 棕褐色调过滤器。
 创建随机变化的白色斑点，以模拟纹理。
 创建随机变化的黑色划痕，以模拟划痕膜。
 将斑点图像和划痕合成到深褐色的图像上。
 */

@implementation HYPOldFilm

+ (NSDictionary *)customAttributes
{
    return @{
        kCIAttributeFilterDisplayName : @"旧照片",
    };
}

- (CIImage *)outputImage {
    return [self outputImage1];
}

- (CIImage *)outputImage1 {
    if (!inputImage) {
        return inputImage;
    }
    CIImage * outputImage;
    
    // 1.
    CIFilter * sepiaTone = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaTone setValue:inputImage forKey:kCIInputImageKey];
    [sepiaTone setValue:[NSNumber numberWithFloat:1] forKey:@"inputIntensity"];
    outputImage = sepiaTone.outputImage;
    
    CIFilter * noise = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIImage * noiseImage = [noise.outputImage imageByCroppingToRect:inputImage.extent];
    
    // 2.Create Randomly Varying White Specks
    CIFilter * whiteSpecks = [CIFilter filterWithName:@"CIColorMatrix"];
    [whiteSpecks setValue:noiseImage forKey:kCIInputImageKey];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputRVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputBVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:0.001 Z:0 W:0.1] forKey:@"inputAVector"];
    /* 按官方文档，白噪点密度过高，合成图充满白噪点，并非所要效果。增加`inputAVector`控制alpha。*/
    
    // 3.Use the CISourceOverCompositing filter to blend the specks with the image
    CIFilter * sourceOverComp = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverComp setValue:whiteSpecks.outputImage forKey:kCIInputImageKey];
    [sourceOverComp setValue:sepiaTone.outputImage forKey:kCIInputBackgroundImageKey];
    outputImage = sourceOverComp.outputImage;
    
    // 4.Create Randomly Varying Dark Scratches
    CGAffineTransform form = CGAffineTransformMakeScale(1.5, 25);
    CIFilter * transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:noiseImage forKey:kCIInputImageKey];
    [transform setValue:[NSValue valueWithBytes:&form objCType:@encode(CGAffineTransform)] forKey:kCIInputTransformKey];
    
    // 5.创建蓝绿色磨砂图滤镜
    CIFilter * darkScratches = [CIFilter filterWithName:@"CIColorMatrix"];
    [darkScratches setValue:[transform.outputImage imageByCroppingToRect:inputImage.extent] forKey:kCIInputImageKey];
    [darkScratches setValue:[CIVector vectorWithX:4 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [darkScratches setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"];
    [darkScratches setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"];
    [darkScratches setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputAVector"];
    [darkScratches setValue:[CIVector vectorWithX:0 Y:1 Z:1 W:1] forKey:@"inputBiasVector"];
    
    // 6.用CIMinimumComponent滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
    CIFilter * miniComp = [CIFilter filterWithName:@"CIMinimumComponent"];
    [miniComp setValue:darkScratches.outputImage forKey:kCIInputImageKey];
    
    // 7.最终组合
    CIFilter * mulComp = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [mulComp setValue:miniComp.outputImage forKey:kCIInputImageKey];
    [mulComp setValue:sourceOverComp.outputImage forKey:kCIInputBackgroundImageKey];
    outputImage = mulComp.outputImage;
    
    return outputImage;
}

- (CIImage *)outputImage2 {
    if (!inputImage) {
        return inputImage;
    }
    CIImage * outputImage;
    
    // 1. Apply Sepia to the Image
    CIFilter * sepiaTone = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaTone setValue:inputImage forKey:kCIInputImageKey];
    [sepiaTone setValue:[NSNumber numberWithFloat:1] forKey:@"inputIntensity"];
    outputImage = sepiaTone.outputImage;
    
    CIFilter * noise = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIImage * noiseImage = [noise.outputImage imageByCroppingToRect:inputImage.extent];
    
    // 2. Create Randomly Varying White Specks
    CIFilter * whiteSpecks = [CIFilter filterWithName:@"CIColorMatrix"];
    [whiteSpecks setValue:noiseImage forKey:kCIInputImageKey];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputRVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputBVector"];
    [whiteSpecks setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    /* 按官网文档，合成图充满白线条 */
    
    // 3. Use the CISourceOverCompositing filter to blend the specks with the image
    CIFilter * sourceOverComp = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverComp setValue:whiteSpecks.outputImage forKey:kCIInputImageKey];
    [sourceOverComp setValue:sepiaTone.outputImage forKey:kCIInputBackgroundImageKey];
    outputImage = sourceOverComp.outputImage;
    
    // 4.
    CGAffineTransform form = CGAffineTransformMakeScale(1.5, 25);
    CIFilter * transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:[noise.outputImage  imageByCroppingToRect:inputImage.extent] forKey:kCIInputImageKey];
    [transform setValue:[NSValue valueWithBytes:&form objCType:@encode(CGAffineTransform)] forKey:kCIInputTransformKey];
    
    // 5.创建蓝绿色磨砂图滤镜
    CIFilter * darkScratchesFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [darkScratchesFilter setValue: transform.outputImage forKey:kCIInputImageKey];
    [darkScratchesFilter setValue: [CIVector vectorWithX:4 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [darkScratchesFilter setValue: [CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"];
    [darkScratchesFilter setValue: [CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"];
    [darkScratchesFilter setValue: [CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputAVector"];
    [darkScratchesFilter setValue: [CIVector vectorWithX:0 Y:1 Z:1 W:1] forKey:@"inputBiasVector"];
    
    // 6.用CIMinimumComponent滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
    CIFilter * minimumComponentFilter = [CIFilter filterWithName:@"CIMinimumComponent"];
    [minimumComponentFilter setValue:darkScratchesFilter.outputImage forKey:kCIInputImageKey];
    
    // 7.最终组合在一起
    CIFilter * multiplyCompositingFilter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [multiplyCompositingFilter setValue:minimumComponentFilter.outputImage forKey:kCIInputBackgroundImageKey];
    [multiplyCompositingFilter setValue:sourceOverComp.outputImage forKey:kCIInputImageKey];
    outputImage = multiplyCompositingFilter.outputImage;
    
    return outputImage;
}

@end
