//
//  HYPCollectionViewCell.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYPCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * imageView;

// asset为视频时, 用于显示时间
@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) UIImageView * iconView;

@property (nonatomic, strong) UIButton * selectBtn;

@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) NSUInteger * selectedNumber;

@property (nonatomic, getter=isShowAccessoryButton) BOOL showAccessoryButton;
@property (nonatomic, getter=isAccessoryEnable) BOOL accessoryEnable;
@property (nonatomic, getter=isAccessorySeleted) BOOL accessorySelected;

@property (nonatomic, strong) void(^selectCallBack)(HYPCollectionViewCell *sender, BOOL selected);

- (void)animationKeyframes;

@end

NS_ASSUME_NONNULL_END
