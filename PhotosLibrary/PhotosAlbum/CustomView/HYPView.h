//
//  HYPView.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYPView : UIView

@end

@interface HYPBottomBar : HYPView

@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * rightBtn;
@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@end


@interface HYPToolBar : HYPView

@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * rightBtn;
@property (nonatomic) UIEdgeInsets contentEdgeInsets;

@property (nonatomic) NSMutableArray * items;
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

NS_ASSUME_NONNULL_END
