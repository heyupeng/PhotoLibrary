//
//  AppDelegate.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/23.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

