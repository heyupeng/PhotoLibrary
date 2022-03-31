//
//  CI.m
//  PhotosLibrary
//
//  Created by Peng on 2022/3/29.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import "CIFilterAttribute.h"

#import <CoreImage/CoreImage.h>

const NSString * kCoefficients = @"Coefficients";
const NSString * kInputRedCoefficients = @"inputRedCoefficients";
const NSString * kInputGreenCoefficients = @"inputGreenCoefficients";
const NSString * kInputBlueCoefficients = @"inputBlueCoefficients";
const NSString * kInputAlphaCoefficients = @"inputAlphaCoefficients";

CIVector * CIVectorCreateWithCIVector(CIVector * vector, CGFloat value, NSUInteger index) {
    size_t count = vector.count;
    CGFloat * floatValues = malloc(sizeof(CGFloat) * count);
    for(int i = 0; i < count; i ++) {
        floatValues[i] = [vector valueAtIndex:i];
    }
    if (index < count) floatValues[index] = value;
    CIVector * newVector = [CIVector vectorWithValues:floatValues count:count];
    free(floatValues);
    return newVector;
}

@interface NSDictionary (toString)

@end

@implementation CIFilterAttribute

+ (instancetype)attributeWithInput:(NSString *)inputKey att:(NSDictionary *)att extent:(CGRect)extent {
    return [[self alloc] initWithInputKey:inputKey attribute:att extent:extent];
}

- (instancetype)initWithInputKey:(NSString *)inputKey attribute:(NSDictionary *)attribute extent:(CGRect)extent {
    self = [super init];
    if (self) {
        _inputKey = inputKey;
        _attribute = attribute;
        
        _attClassName = [attribute objectForKey:kCIAttributeClass];
        _attDisplayName = [attribute objectForKey:kCIAttributeDisplayName];
        _attDescription = [attribute objectForKey:kCIAttributeDescription];
        _attType = [attribute objectForKey:kCIAttributeType];
        
        _attDefaultValue = [attribute objectForKey:kCIAttributeDefault];
        
        _attIdentityValue = [attribute objectForKey:kCIAttributeIdentity];
        _attSliderMaxValue = [attribute objectForKey:kCIAttributeSliderMax];
        _attSliderMinValue = [attribute objectForKey:kCIAttributeSliderMin];
        
        _attMaxValue = [attribute objectForKey:kCIAttributeMax];
        _attMinValue = [attribute objectForKey:kCIAttributeMin];
        
        if ([_attType isEqualToString:kCIAttributeTypePosition]) {
            // kCIAttributeTypePosition 
            [self setupSliderValueForPositionWithExtent:extent];
        }
        
        _value = _attDefaultValue;
    }
    return self;
}

- (void)setupSliderValueForPositionWithExtent:(CGRect)extent {
    CGSize size = extent.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(300, 300);
    }
    CIVector * max = [CIVector vectorWithX:size.width Y:size.height];
    _attSliderMaxValue = max;
    
    CIVector * min = [CIVector vectorWithX:-50 Y:-50];
    _attMinValue = min;
}

- (void)updateValue:(CGFloat)floatValue atElementIndex:(NSUInteger)index {
    NSString * className = _attClassName;
    id newValue;
    
    if ([className isEqualToString:NSStringFromClass(NSNumber.class)]) {
        if ([_attType isEqualToString:kCIAttributeTypeScalar]) {
            newValue = [NSNumber numberWithFloat:floatValue];
        } else {
            newValue = [NSNumber numberWithInteger:(NSInteger)floatValue];
        }
    }
    else if ([className isEqualToString:@"CIVector"]) {
        CIVector * oldVector = self.value;
        newValue = CIVectorCreateWithCIVector(oldVector, floatValue, index);
        
    }
    self.value = newValue;
}

- (NSUInteger)elementCount {
    NSString * className = _attClassName;
    if ([className isEqualToString:NSStringFromClass([NSNumber class])]) {
        return 1;
    }
    else if ([className isEqualToString:@"CIVector"]) {
        return [(CIVector *)_attDefaultValue count];
    }
    return 0;
}

- (id)sliderMinValue {
    if (_attSliderMinValue) {
        return _attSliderMinValue;;
    }
    if (_attMinValue) {
        return _attMinValue;
    }
    
    NSString * inputKey = self.inputKey;
    NSString * className = _attClassName;
    if ([className isEqualToString:@"NSNumber"]) {
        return @(-10);
    }
    if ([className isEqualToString:@"CIVector"]) {
        CIVector  * vector;
        if ([inputKey isEqualToString:kCIInputCenterKey]) {
            CGPoint point = CGPointZero;
            vector = [CIVector vectorWithCGPoint:point];
        }
        else if ([inputKey isEqualToString:kCIInputExtentKey]) {
            CGRect rect = CGRectMake(-100, -100, 0, 0);
            vector = [CIVector vectorWithCGRect:rect];
        }
        else if ([inputKey containsString:kCoefficients.copy]) {
            return [CIVector vectorWithX:-1 Y:-1 Z:-1 W:-1];
        }
        else if ([_attType isEqualToString:kCIAttributeTypePosition]) {
            vector = [CIVector vectorWithCGPoint:CGPointMake(-100, -100)];
        }
        return vector;
    }
    return nil;
}

- (id)sliderMaxValue {
    if (_attSliderMaxValue) {
        return _attSliderMaxValue;;
    }
    if (_attMaxValue) {
        return _attMaxValue;
    }
    
    NSString * inputKey = self.inputKey;
    NSString * className = _attClassName;
    if ([className isEqualToString:@"NSNumber"]) {
        return @(10);
    }
    if ([className isEqualToString:@"CIVector"]) {
        CIVector  * vector;
        if ([inputKey isEqualToString:kCIInputCenterKey]) {
            CGPoint point = CGPointMake(300, 300);
            vector = [CIVector vectorWithCGPoint:point];
        }
        else if ([inputKey isEqualToString:kCIInputExtentKey]) {
            CGRect rect = CGRectMake(2000, 2000, 2000, 2000); // CIImage.extent
            vector = [CIVector vectorWithCGRect:rect];
        }
        else if ([inputKey containsString:kCoefficients.copy]) {
            return [CIVector vectorWithX:2 Y:2 Z:2 W:2];
        }
        else if ([_attType isEqualToString:kCIAttributeTypePosition]) {
            vector = [CIVector vectorWithCGPoint:CGPointMake(500, 500)];
        }
        return vector;
    }
    return nil;
}

@end
