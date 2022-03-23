//
//  MyHazeFilter.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyHazeFilter : CIFilter
{
    CIImage * inputImage;
    CIColor * inputColor;
    NSNumber * inputDistance;
    NSNumber * inputSlope;
}
@end

NS_ASSUME_NONNULL_END
