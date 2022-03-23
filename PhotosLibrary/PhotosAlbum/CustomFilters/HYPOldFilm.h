//
//  HYPOldFilm.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYPOldFilm : CIFilter
{
    CIImage * inputImage;
}
@end

NS_ASSUME_NONNULL_END
