//
//  CIFilterAttribute.h
//  PhotosLibrary
//
//  Created by Peng on 2022/3/29.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class CIVector;
FOUNDATION_EXTERN CIVector * CIVectorCreateWithCIVector(CIVector * vector, CGFloat value, NSUInteger index);

@interface CIFilterAttribute : NSObject

@property (nonatomic, strong) NSString * inputKey;
@property (nonatomic, strong) NSDictionary * attribute;

@property (nonatomic, strong) NSString * attClassName;
@property (nonatomic, strong) NSString * attDisplayName;
@property (nonatomic, strong) NSString * attDescription;
@property (nonatomic, strong) NSString * attType;

@property (nonatomic, strong) id attDefaultValue;
@property (nonatomic, strong) id attIdentityValue;
@property (nonatomic, strong) id attSliderMaxValue;
@property (nonatomic, strong) id attSliderMinValue;
@property (nonatomic, strong) id attMaxValue;
@property (nonatomic, strong) id attMinValue;

@property (nonatomic, strong) id value;

@property (nonatomic, readonly) NSUInteger elementCount;
@property (nonatomic, readonly) id sliderMaxValue;
@property (nonatomic, readonly) id sliderMinValue;

- (instancetype)initWithInputKey:(NSString *)inputKey attribute:(NSDictionary *)attribute extent:(CGRect)extent;

- (void)updateValue:(CGFloat)floatValue atElementIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
