//
//  ChromaKeyEffect.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIFilter (ChromaKeyEffect)

+ (NSData *)chromaKeyCubeDataWithDimension:(int)size HuesFrom:(CGFloat)minHue to:(CGFloat)maxHue;

@end

@interface ChromaKeyEffect : CIFilter
{
    CIImage * inputImage;
    CIImage * inputBackgroundImage;
    
    NSNumber * inputCubeDimension;
//    NSData * inputCubeData;
    NSNumber * inputMinHue;
    NSNumber * inputMaxHue;
}
@end

NS_ASSUME_NONNULL_END
