//
//  MyHazeFilter.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "MyHazeFilter.h"

/// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_custom_filters/ci_custom_filters.html#//apple_ref/doc/uid/TP30001185-CH6-SW1
@implementation MyHazeFilter

static CIKernel * hazeRemovalKernel = nil;

- (id)init
{
    if(hazeRemovalKernel == nil)// 1
    {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]]; // 2
        NSString * path = [bundle pathForResource:@"MyHazeRemoval" ofType:@"cikernel"];
        NSString * code = [NSString stringWithContentsOfFile:path]; // 3
        NSArray * kernels = [CIKernel kernelsWithString:code]; // 4
        hazeRemovalKernel = kernels [0]; // 5
    }
    return [super init];
}

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputDistance" :  @{
                     kCIAttributeMin       : @0.0,
                     kCIAttributeMax       : @1.0,
                     kCIAttributeSliderMin : @0.0,
                     kCIAttributeSliderMax : @0.7,
                     kCIAttributeDefault   : @0.2,
                     kCIAttributeIdentity  : @0.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputSlope" : @{
                     kCIAttributeSliderMin : @-0.01,
                     kCIAttributeSliderMax : @0.01,
                     kCIAttributeDefault   : @0.00,
                     kCIAttributeIdentity  : @0.00,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             kCIInputColorKey : @{
                     kCIAttributeDefault : [CIColor colorWithRed:1.0
                                                           green:1.0
                                                            blue:1.0
                                                           alpha:1.0]
                     },
             };
}

- (CIImage *)outputImage
{
    CISampler *src = [CISampler samplerWithImage: inputImage];
    inputColor = [CIColor colorWithRed:0.2 green:0.2 blue:0.4 alpha:1.0];
    
    return [hazeRemovalKernel applyWithExtent:inputImage.extent  roiCallback:^CGRect(int index, CGRect destRect) {
        return destRect;
    } arguments:@[src,inputColor, @0.25, @0.0]];
    
//    return [hazeRemovalKernel applyWithExtent:inputImage.extent  roiCallback:^CGRect(int index, CGRect destRect) {
//        return destRect;
//    } arguments:@[src, @0.2]];

//    return [self apply: hazeRemovalKernel, src, inputColor, inputDistance, inputSlope, kCIApplyOptionDefinition, [src definition], nil];
    
    return inputImage;
}

//+ (void)initialize
//{
//    [CIFilter registerFilterName: @"MyHazeRemoval"
//                     constructor: self
//                 classAttributes:
//     @{kCIAttributeFilterDisplayName : @"Haze Remover",
//       kCIAttributeFilterCategories : @[
//               kCICategoryColorAdjustment, kCICategoryVideo,
//               kCICategoryStillImage, kCICategoryInterlaced,
//               kCICategoryNonSquarePixels]}
//     ];
//}
//
//+ (CIFilter *)filterWithName: (NSString *)name
//{
//    CIFilter  *filter;
//    filter = [[self alloc] init];
//    return filter;
//}
@end
