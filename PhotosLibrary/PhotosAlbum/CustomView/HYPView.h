//
//  HYPView.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static const CGFloat UINavigationBarBackgroundEffectAlpha = 0.85;

@interface HYPView : UIView

@end

@interface HYPTopBar : UIView

@property (nonatomic, strong) UIView * contentView;

@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * rightBtn;
@property (nonatomic, readonly) NSArray * leftItems;

@end

@interface HYPBottomBar : HYPView

@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * rightBtn;
@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@end


@protocol HYPRefreshProperty <NSObject>

@optional
- (void)refreshViewFrame:(UIView *)view;
@end

@interface HYPCropView : HYPView
{
    CAShapeLayer * girdLineLayer;
}
@property (nonatomic, weak) id<HYPRefreshProperty> delegate;
@property (nonatomic, strong) void(^refreshPropertyCallback)(UIView * view, NSString *key);
@end


@interface HYPScrollView : UIScrollView

@end

@interface HYPSrollImageView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) HYPScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;

// Default is NO. if set YES, size of imageView will reset when set image.
@property (nonatomic) BOOL autoResizeImageView;

@property (nonatomic) BOOL autoResizeContentView;

@end


@protocol ToolBarDelegate;

@interface ToolBar : UIView

@property (nonatomic, weak) NSString * selectedItem;
@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;

@property (nonatomic, weak) id<ToolBarDelegate> delegate;

@property (nonatomic, strong) NSArray<UITabBarItem *> * items;

@end

@protocol ToolBarDelegate<NSObject>
@optional
- (void)toolbar:(ToolBar *)tabBar didSelectItem:(__kindof UIBarItem *)item;
@end

NS_ASSUME_NONNULL_END
