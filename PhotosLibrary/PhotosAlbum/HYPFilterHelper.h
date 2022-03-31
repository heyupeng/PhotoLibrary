//
//  HYPFilterHelper.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

#import "ColorConversion.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CICategoryType) {
    CICategoryTypeBlur,
    CICategoryTypeColorAdjustment,
    CICategoryTypeColorEffect,
    CICategoryTypeCompositeOperation,
    CICategoryTypeDistortionEffect,
    CICategoryTypeGenerator,
    CICategoryTypeGeometryAdjustment,
    CICategoryTypeGradient,
    CICategoryTypeHalftoneEffect,
    CICategoryTypeReduction,
    CICategoryTypeSharpen,
    CICategoryTypeStylize,
    CICategoryTypeTileEffect,
    CICategoryTypeTransition,
};

NSData * colorCubeTableCreateWithDimension(unsigned int dimension, float minHue, float maxHue);

UIKIT_EXTERN UIImage * CIImageToUIImage(CIImage * ciImage);

@interface HYPFilterHelper : NSObject

+ (NSArray *)colorEffectFilterNames;

+ (CIFilter
   *)chromaKeyFilterWithDimension:(NSUInteger)dimension HuesFrom:(CGFloat)minHue to:(CGFloat)maxHue;

@end

NS_ASSUME_NONNULL_END
