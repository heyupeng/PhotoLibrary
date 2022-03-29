//
//  UITableViewCell+AccessoryButtonTapped.h
//  PhotosLibrary
//
//  Created by Peng on 2022/3/29.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (AccessoryButtonTapped)

/// 通知 UITableView 附加按钮 AccessoryButton 已点击，应该调用 UITableViewDelegate 对应的协议接口。
/// @param sender Cell 上的子视图，UIControl 对象。
/// @param event 响应事件
- (void)sendAccessoryButtonTappedActionToTableView:(nullable UIControl *)sender forEvent:(nullable UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
