//
//  HYPCollectionViewCell.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPCollectionViewCell.h"

typedef NS_ENUM(NSInteger, HYPEdgeInsetsType) {
    HYPEdgeInsetsTypeDefault = 0,
    HYPEdgeInsetsTypeLeftTop ,
    HYPEdgeInsetsTypeLeftBottom ,
    HYPEdgeInsetsTypeCenter ,
    HYPEdgeInsetsTypeRihtTop,
};

@interface HYPButton : UIButton
@property (nonatomic) UIEdgeInsets eventEdgeInsets;
@end

@implementation HYPButton

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (!self.hidden && [self pointInside:point withEvent:event])
        return self;
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inSide = [super pointInside:point withEvent:event];
    CGRect frame = [self respondsRectForBounds:self.bounds withEdgeInsets:_eventEdgeInsets];
    inSide = CGRectContainsPoint(frame, point);
    return inSide;
}

- (CGRect)respondsRectForBounds:(CGRect)bounds withEdgeInsets:(UIEdgeInsets)edgeInsets {
    CGRect frame = bounds;
    frame.origin.x += _eventEdgeInsets.left;
    frame.origin.y += _eventEdgeInsets.top;
    frame.size.width += - _eventEdgeInsets.right - _eventEdgeInsets.left;
    frame.size.height += - _eventEdgeInsets.bottom - _eventEdgeInsets.top;
    return frame;
}

@end

@interface HYPCollectionViewCell()
@property (nonatomic, strong) UIView * enableMaskView;

@property (nonatomic, strong) UILabel * selectedIndexLabel;
@end

@implementation HYPCollectionViewCell

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    };
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _accessoryEnable = YES;
    _accessorySelected = NO;
    
    self.contentView.layer.masksToBounds = YES;
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView .contentMode =UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    [self enableMaskView];
    UILabel * label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:label];
    _timeLabel = label;
    
    UIImageView * iconView = [[UIImageView alloc] init];
    iconView .contentMode =UIViewContentModeScaleAspectFill;
    iconView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:iconView];
    _iconView = iconView;
    _iconView.frame = CGRectMake(5, 5, 25, 25);
    _iconView.layer.cornerRadius = CGRectGetHeight(_iconView.frame) * 0.5;
    
    HYPButton * selectBtn = (HYPButton*)self.selectBtn;
    selectBtn.frame = CGRectMake(2, 2, 30, 30);
    selectBtn.eventEdgeInsets = UIEdgeInsetsMake(0, CGRectGetWidth(selectBtn.frame) - 44, CGRectGetHeight(selectBtn.frame) - 44, 0);
    
    [selectBtn setImage:[UIImage imageNamed:@"style_bar_cell_select_def"] forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:@"style_bar_cell_select_num"] forState:UIControlStateSelected];
    
    self.selectedIndexLabel.frame = selectBtn.frame;
    
}

- (void)layoutSubviews {
    _imageView.frame = self.contentView.bounds;
    _timeLabel.frame = CGRectMake(0, CGRectGetHeight(self.contentView.frame) - 30, CGRectGetWidth(self.contentView.frame), 30);
    
    CGRect frame = _selectBtn.frame;
    frame.origin.x = CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(frame) - 2;
    _selectBtn.frame = frame;
    
    frame.origin.x += _selectBtn.imageEdgeInsets.left/2.0;
    frame.origin.y += -_selectBtn.imageEdgeInsets.bottom/2.0;
    _selectedIndexLabel.frame = frame;
    
    self.enableMaskView.frame = self.contentView.frame;
}

- (void)selectBtnClick:(UIButton *)sender {
    NSLog(@"%d", sender.selected);
    if (self.selectCallBack) {
        self.selectCallBack(self, _accessorySelected);
    }
}

- (void)animationKeyframes {
    [UIView animateKeyframesWithDuration:0.15 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        self.selectBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.15 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            self.selectBtn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
}
#pragma mark - set function
- (void)setSelectedIndex:(NSUInteger)seletedIndex {
    _selectedIndex = seletedIndex;
    
    if (_selectedIndex == -1) {
        _accessorySelected = NO;
        _selectBtn.selected = NO;
        
        self.selectedIndexLabel.text = @" ";
        self.selectedIndexLabel.hidden = YES;
    } else {
        _accessorySelected = YES;
        _selectBtn.selected = YES;
        
        self.selectedIndexLabel.text = [NSString stringWithFormat:@"%ld", seletedIndex];
        self.selectedIndexLabel.hidden = NO;
    }
}

- (void)setAccessoryEnable:(BOOL)accessoryEnable {
    _accessoryEnable = accessoryEnable;
    self.enableMaskView.hidden = _accessoryEnable;
}

- (void)setAccessorySelected:(BOOL)accessorySelected {
    _accessorySelected = accessorySelected;
}

- (void)setShowAccessoryButton:(BOOL)showAccessoryButton {
    _showAccessoryButton = showAccessoryButton;
    self.selectBtn.hidden = !_showAccessoryButton;
}

#pragma mark - lazy load
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        UIButton * selectBtn = [HYPButton buttonWithType:UIButtonTypeCustom];
        [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectBtn];
        _selectBtn = selectBtn;
    }
    return _selectBtn;
}
- (UILabel *)selectedIndexLabel {
    if (!_selectedIndexLabel) {
        UILabel * label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label];
        _selectedIndexLabel = label;
    }
    return _selectedIndexLabel;
}

- (UIView *)enableMaskView {
    if (!_enableMaskView) {
        UIView * mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        mask.hidden = YES;
        [self.contentView addSubview:mask];
        _enableMaskView = mask;
    }
    return _enableMaskView;
}
@end
