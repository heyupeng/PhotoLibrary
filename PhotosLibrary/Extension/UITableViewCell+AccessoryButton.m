//
//  UITableViewCell+AccessoryButton.m
//  PhotosLibrary
//
//  Created by Peng on 2022/3/29.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import "UITableViewCell+AccessoryButton.h"

@implementation UITableViewCell (AccessoryButtonTapped)

/// 通知 UITableView 附加按钮 AccessoryButton 已点击，应该调用 UITableViewDelegate 对应的协议接口。
/// @param sender Cell 上的子视图，UIControl 对象。
/// @param event 响应事件
- (void)sendAccessoryButtonTappedActionToTableView:(nullable UIControl *)sender forEvent:(nullable UIEvent *)event {
    UIView * target = self.superview;
    if (target && [target isKindOfClass:[UITableView class]]) {
#if 0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL selector = @selector(_accessoryButtonAction:);
#pragma clang diagnostic pop
#else
        SEL selector = NSSelectorFromString(@"_accessoryButtonAction:");
#endif
        /* 即调用 [UIApplication sendAction:to:from:forEvent:] */
        [sender sendAction:selector to:target forEvent:event];
        [UIApplication.sharedApplication sendAction:selector to:target from:sender forEvent:event];
    }
}

@end
