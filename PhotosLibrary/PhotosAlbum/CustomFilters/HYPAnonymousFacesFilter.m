//
//  HYPAnonymousFacesFilter.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPAnonymousFacesFilter.h"

@implementation HYPAnonymousFacesFilter

- (id)init
{
    
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

// Build a Mask From the Faces Detected in the Image
- (CIImage *)outputImage {
    
    // Features Detector
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:nil];
    NSArray *faceArray = [detector featuresInImage:inputImage options:nil];
    
    if (faceArray.count < 1) {
        return inputImage;
    }
    
    // 1.Create a Pixellated version of the image
    CIFilter * pixellated = [CIFilter filterWithName:@"CIPixellate"];
    [pixellated setValue:inputImage forKey:kCIInputImageKey];
    [pixellated setValue:[NSNumber numberWithInt:MAX(inputImage.extent.size.width, inputImage.extent.size.height)/60] forKey:kCIInputScaleKey];
    
    // 2.Build a Mask From the Faces Detected in the Image
    // Create a green circle to cover the rects that are returned.
    CIImage *maskImage = nil;
    
    for (CIFaceFeature *f in faceArray) {
        CGFloat centerX = f.bounds.origin.x + f.bounds.size.width / 2.0;
        CGFloat centerY = f.bounds.origin.y + f.bounds.size.height / 2.0;
        CGFloat radius = MIN(f.bounds.size.width, f.bounds.size.height) / 1.75;
        
        NSDictionary * params = @{
          @"inputRadius0": @(radius),
          @"inputRadius1": @(radius + 1.0f),
          @"inputColor0": [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
          @"inputColor1": [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
          kCIInputCenterKey: [CIVector vectorWithX:centerX Y:centerY],
                                  };
        CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient" withInputParameters:params];
        CIImage *circleImage = [[radialGradient valueForKey:kCIOutputImageKey] imageByCroppingToRect:inputImage.extent];
        if (nil == maskImage)
            maskImage = circleImage;
        else
            maskImage = [[CIFilter filterWithName:@"CISourceOverCompositing" withInputParameters:@{kCIInputImageKey: circleImage, kCIInputBackgroundImageKey: maskImage}] valueForKey:kCIOutputImageKey];
    }
//    return [[CIFilter filterWithName:@"CISourceOverCompositing" withInputParameters:@{kCIInputImageKey: maskImage, kCIInputBackgroundImageKey: inputImage}] valueForKey:kCIOutputImageKey];
    
    // 3.Blend the Pixellated Image, the Mask, and the Original Image
    CIFilter * blendWithMask = [CIFilter filterWithName:@"CIBlendWithMask"];
    [blendWithMask setValuesForKeysWithDictionary:@{kCIInputBackgroundImageKey: inputImage,
                                                    kCIInputMaskImageKey: maskImage,
                                                    kCIInputImageKey:pixellated.outputImage
                                                    }];
    return [blendWithMask valueForKey:kCIOutputImageKey];
}

+ (void)initialize
{
    [CIFilter registerFilterName: @"HYPAnonymousFacesFilter"
                     constructor: self
                 classAttributes:
     @{kCIAttributeFilterDisplayName : @"HYPAnonymousFacesFilter",
       kCIAttributeFilterCategories : @[
               kCICategoryColorAdjustment, kCICategoryVideo,
               kCICategoryStillImage, kCICategoryInterlaced,
               kCICategoryNonSquarePixels]}
     ];
}

+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    return filter;
}
@end

