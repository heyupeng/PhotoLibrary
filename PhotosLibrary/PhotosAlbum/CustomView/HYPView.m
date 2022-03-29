//
//  HYPView.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPView.h"
#import "GeometryExtension.h"

@implementation UIView (SafeAreaInsetsInWindow)

- (UIEdgeInsets)safeAreaInsetsInWindow {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    UIWindow * window;
    if (self.window) {
        window = self.window;
        NSLog(@"ToolBar.window");
    } else {
        NSLog(@"UIApplication.window");
#if 1
        window = UIApplication.sharedApplication.delegate.window;
#else
        if (@available(iOS 13.0, *)) {
            UIWindowScene * windowScene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];
            window = [windowScene.windows firstObject];
        } else {
            // Fallback on earlier versions
            window = UIApplication.sharedApplication.keyWindow;
        }
#endif
    }
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = window.safeAreaInsets;
    } else {
        // Fallback on earlier versions
    }
    return safeAreaInsets;
}

@end

@implementation HYPView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface UIBezierPath (CustomBezierPath)
+ (UIBezierPath *)bezierPathWithborderRightAngleBox:(CGRect)bounds lineLenght:(float)lineLength;

@end

@implementation UIBezierPath (CustomBezierPath)

+ (UIBezierPath *)bezierPathWithborderRightAngleBox:(CGRect)bounds lineLenght:(float)lineLength {
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint leftUpPoint = CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    [path moveToPoint:CGPointMake(leftUpPoint.x, leftUpPoint.y + lineLength)];
    [path addLineToPoint:CGPointMake(leftUpPoint.x, leftUpPoint.y)];
    [path addLineToPoint:CGPointMake(leftUpPoint.x + lineLength, leftUpPoint.y)];
    
    CGPoint rightUpPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    [path moveToPoint:CGPointMake(rightUpPoint.x - lineLength, rightUpPoint.y)];
    [path addLineToPoint:CGPointMake(rightUpPoint.x, rightUpPoint.y)];
    [path addLineToPoint:CGPointMake(rightUpPoint.x, rightUpPoint.y + lineLength)];
    
    CGPoint rightDownPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    [path moveToPoint:CGPointMake(rightDownPoint.x, rightDownPoint.y - lineLength)];
    [path addLineToPoint:CGPointMake(rightDownPoint.x, rightDownPoint.y)];
    [path addLineToPoint:CGPointMake(rightDownPoint.x - lineLength, rightDownPoint.y)];
    
    CGPoint leftDownPoint = CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
    [path moveToPoint:CGPointMake(leftDownPoint.x + lineLength, leftDownPoint.y)];
    [path addLineToPoint:CGPointMake(leftDownPoint.x, leftDownPoint.y)];
    [path addLineToPoint:CGPointMake(leftDownPoint.x, leftDownPoint.y - lineLength)];
    return path;
}

@end

@interface HYPTopBar ()

@property (nonatomic, weak) UIView * backgroundView;

@property (nonatomic, strong) UILabel * titleLabel;
@end

@implementation HYPTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _contentEdgeInsets = UIEdgeInsetsZero;
    self.backgroundColor = [[UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1.0] colorWithAlphaComponent:UINavigationBarBackgroundEffectAlpha];
    
    if (!_backgroundView) {
        UIView * view = [[UIView alloc] init];
        view.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:0.2];
        _backgroundView = view;
        [self addSubview:view];
    }
    
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
    }
}

- (CGRect)backgroundRectWithBounds:(CGRect)rect {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    } else {
        // Fallback on earlier versions
    }
    
    CGRect backgroundRect = rect;
    backgroundRect = [self convertRect:rect toView:self.window];
    if (backgroundRect.origin.y > safeAreaInsets.top) {
        backgroundRect.origin.y = 0;
    } else {
        backgroundRect.origin.y = - safeAreaInsets.top;
        backgroundRect.size.height += safeAreaInsets.top;
    }
    return backgroundRect;
}

- (CGRect)titleRectWithContentContentBounds:(CGRect)bounds {
    if (_title.length == 0) return CGRectZero;
    
    CGRect textRect = [self.titleLabel textRectForBounds:bounds limitedToNumberOfLines:2];
    textRect.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(textRect)) * 0.5;
    textRect.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(textRect)) * 0.5;
    return textRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    // backgroundView
    CGRect backgroundRect = [self backgroundRectWithBounds:self.bounds];
    _backgroundView.frame = backgroundRect;
    
    // _contentView frame
    frame = CGRectEdgeInsets(frame, _contentEdgeInsets);
    _contentView.frame = frame;
    
    self.titleLabel.frame = [self titleRectWithContentContentBounds:_contentView.bounds];
}

- (void)setTitle:(NSString *)title {
    if ([title isEqualToString:_title]) { return; }
    _title = title;
    
    self.titleLabel.text = title;
    
    [self setNeedsLayout];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        _titleLabel.textColor = UIColor.whiteColor;
        [_contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentView addSubview:leftBtn];
        _leftBtn = leftBtn;
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentView addSubview:rightBtn];
        _rightBtn = rightBtn;
    }
    return _rightBtn;
}

@end

@interface HYPBottomBar ()

@end

@implementation HYPBottomBar

- (void)setup {
    _contentEdgeInsets = UIEdgeInsetsZero;
    self.backgroundColor = [[UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1.0] colorWithAlphaComponent:UINavigationBarBackgroundEffectAlpha];
    _contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    // _contentView frame
    frame.origin = CGPointMake(_contentEdgeInsets.left, _contentEdgeInsets.top);
    frame.size.width -= _contentEdgeInsets.right + _contentEdgeInsets.left;
    frame.size.height -= _contentEdgeInsets.top + _contentEdgeInsets.bottom;
    _contentView.frame = frame;
    
    if (_leftBtn) {
        frame = CGRectMake(10, 7, 60, 30);
        _leftBtn.frame = frame;
    }
    if (_rightBtn) {
        frame = CGRectMake(0, 7, 60, 30);
        frame.origin.x = CGRectGetWidth(_contentView.frame) - CGRectGetWidth(frame) - 10;
        _rightBtn.frame = frame;
    }
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentView addSubview:leftBtn];
        _leftBtn = leftBtn;
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        UIButton * rightBtn = [[UIButton alloc] init]; //[UIButton buttonWithType:UIButtonTypeCustom];
        [_contentView addSubview:rightBtn];
        _rightBtn = rightBtn;
    }
    return _rightBtn;
}

@end

/* 去除scrollView 单击事件干扰*/
@implementation HYPScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView * superview = self.superview;
    [superview touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UIView * superview = self.superview;
    [superview touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView * superview = self.superview;
    [superview touchesEnded:touches withEvent:event];
}

@end

@implementation HYPSrollImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _autoResizeImageView = NO;
    _autoResizeContentView = NO;
    
    _scrollView = [[HYPScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.canCancelContentTouches = NO;
    _scrollView.multipleTouchEnabled =YES;
    _scrollView.exclusiveTouch = YES;
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1.0;
    [self addSubview:_scrollView];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    self.imageView.frame = _scrollView.bounds;
}

- (void)refreshImageViewCenter {
    CGPoint center = CGRectGetInnerCenterPoint(_scrollView.bounds);
    if (_scrollView.contentSize.width > CGRectGetWidth(_scrollView.frame)) {
        center.x = _scrollView.contentSize.width * 0.5;
    }
    if (_scrollView.contentSize.height >CGRectGetHeight(_scrollView.frame)) {
        center.y = _scrollView.contentSize.height * 0.5;
    }
    _imageView.center = center;
}

#pragma mark - Setter And Getter Func
- (void)setAutoResizeImageView:(BOOL)autoResizeImageView {
    if (_autoResizeImageView == autoResizeImageView) return;
    _autoResizeImageView = autoResizeImageView;
    if (_autoResizeImageView) {
        [self addObserverForImageViewResizeWhileSetImage];
    } else {
        [self removeObserverForImageViewResizeWhileSetImage];
    }
    
}
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    NSLog(@"EndZooming:%.2f",scale);
    /* 增加监听修改imageView size */
    //    CGSize contentSize = scrollView.contentSize;
    //    contentSize.height = _imageView.image.size.height / _imageView.image.size.width * contentSize.width;
    //    scrollView.contentSize = contentSize;
    //    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y * 0.5);
    
    [self refreshImageViewCenter];
}

#pragma mark - Private Observer Func
- (void)addObserverForImageViewResizeWhileSetImage {
    [self addObserver:self forKeyPath:@"imageView.image" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserverForImageViewResizeWhileSetImage {
    [self removeObserver:self forKeyPath:@"imageView.image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual: self] && [keyPath isEqualToString:@"imageView.image"]) {
        CGSize imageSize = CGSizeZero;
        UIImage * NewImage = self.imageView.image;
        if (!NewImage) { return;}
        
        imageSize = NewImage.size;
        CGSize contentSize = [self resizeForImageSize:imageSize];
        self.imageView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
        self.scrollView.zoomScale = 1;
        [self refreshImageViewCenter];
    }
}

- (CGSize)resizeForImageSize:(CGSize)imageSize {
    CGSize contentSize = self.bounds.size;
    if (imageSize.width == 0 || imageSize.height == 0) { return contentSize;}
    
    CGFloat imgRatio = imageSize.width / imageSize.height;
    CGFloat imgViewHeight = contentSize.width / imgRatio;
    
    if (imgViewHeight <= CGRectGetHeight(self.bounds)) {
        contentSize.height = imgViewHeight;
    } else {
        contentSize.width = contentSize.height * imgRatio;
    }
    return contentSize;
}

#pragma mark - style life
- (void)dealloc {
    self.autoResizeContentView = NO;
}
@end


const NSUInteger GirdLineCount = 9;

@implementation HYPCropView
{
    BOOL isShowGirdLines;
    float alp;
    
    CAShapeLayer * bordLayer;
    
    BOOL isChangeFrame;
    CGPoint touchPoint;
    
    float hotDistance;
    BOOL hotArea;
    
    CGSize minSize;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    hotDistance = 30;
    minSize = CGSizeMake(50, 50);
    girdLineLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer: girdLineLayer];
    girdLineLayer.opacity = 0.2;
    
    bordLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:bordLayer];
}

- (void)drawRect:(CGRect)rect {
    girdLineLayer.lineWidth = 1;
    girdLineLayer.backgroundColor = [[UIColor redColor]CGColor];
    girdLineLayer.strokeColor = [[UIColor whiteColor] CGColor];
    girdLineLayer.fillColor = [[UIColor clearColor] CGColor];
    girdLineLayer.path = [self girdLinePath:GirdLineCount].CGPath;
    
    float lineWidth = 2.5;
    bordLayer.lineWidth = lineWidth;
    bordLayer.strokeColor = [[UIColor redColor] CGColor];
    bordLayer.fillColor = [[UIColor clearColor] CGColor];
    CGRect corBounds = CGRectInset(self.bounds, lineWidth * -0.5, lineWidth * -0.5);
    UIBezierPath * p1 = [UIBezierPath bezierPathWithborderRightAngleBox:corBounds lineLenght:15];
    bordLayer.path = p1.CGPath;
}

- (UIBezierPath *)girdLinePath:(NSUInteger)girdCount {
    UIBezierPath * path = [UIBezierPath bezierPath];
    for (int i = 1; i < girdCount; i ++) {
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds) * i / (float)girdCount)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) * i / (float)girdCount)];
    }
    
    for (int i = 1; i < girdCount; i ++) {
        CGPoint startPoint = CGPointMake(CGRectGetWidth(self.bounds) * i / (float)girdCount, 0);
        CGPoint endPoint = CGPointMake(CGRectGetWidth(self.bounds) * i / (float)girdCount, CGRectGetHeight(self.bounds));
        [path moveToPoint:startPoint];
        [path addLineToPoint:endPoint];
    }
    return path;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    if (view == self &&  CGRectContainsPoint(CGRectInset(self.bounds, hotDistance, hotDistance), point)) {
        return nil;
    };
    if (!view && CGRectContainsPoint(CGRectInset(self.bounds, -hotDistance, -hotDistance), point)) {
        return self;
    };
    return view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch * touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
    
    isShowGirdLines = YES;
    [self showGird:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"%@", NSStringFromCGPoint(point));
    
    [self refreshFrameWithPoint:point];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    isShowGirdLines = NO;
    [self showGird:NO];
}

- (void)dealloc {
    _refreshPropertyCallback = nil;
}

// MARK: Private
- (void)refrshProperty:(NSString *)key {
    if (_refreshPropertyCallback) {
        _refreshPropertyCallback(self, key);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewFrame:)]) {
        [self.delegate refreshViewFrame:self];
    }
}
- (void)refreshFrameWithPoint:(CGPoint)point {
    CGRect frame = self.frame;
    int n = 5;
    int xIndex = point.x / frame.size.width * n;
    if (xIndex < 1) {
        if (frame.size.width - point.x > minSize.width) {
            frame.origin.x += point.x;
            frame.size.width -= point.x;
        }
    } else if (xIndex < n - 1) {
        
    } else {
        if (point.x > minSize.width) {
            frame.size.width = point.x;
        }
    }
    
    int yIndex = point.y / frame.size.height * n;
    if (yIndex < 1) {
        if (frame.size.height - point.y > minSize.height) {
            frame.origin.y += point.y;
            frame.size.height -= point.y;
        }
    } else if (yIndex < n - 1) {
        
    } else {
        if (point.y > minSize.height) {
            frame.size.height = point.y;
        }
    }
    
    self.frame = frame;
    [self setNeedsDisplay];
    
    [self refrshProperty: @"frame"];
}

- (void)showGird:(BOOL)show {
    float opacity = 0.2;
    if (show) {
        opacity = 1;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self->girdLineLayer.opacity = opacity;
    } completion:nil];
    
//    CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    ani.toValue = [NSNumber numberWithFloat:alp];
//    ani.duration = 0.5;
//    ani.beginTime = 0;
//    ani.fillMode = kCAFillModeForwards;
//    ani.removedOnCompletion = NO;
//
//    [girdLineLayer addAnimation:ani forKey:@"opacityAni"];
}
@end
