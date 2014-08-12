//
//  AppDelegate.h
//  Smartime
//
//  Created by Ricardo Pereira on 07/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *deviceUDID;
@property (nonatomic, copy) void (^eventAfterFetchData)(NSObject*);

@end
