//
//  CoronaLiveBuildFileManagerDelegateImpl.h
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
//

#import <Foundation/Foundation.h>
#import "CoronaLiveBuildFileManager.h"

@interface CoronaLiveBuildFileManagerDelegateImpl : NSObject <CoronaFileManagerDelegate>

- (id)initWithController:(UIViewController *)controller;

- (void)relaunch;
- (void)runWithPath:(NSString *)projectPath;
- (void)setActivityIndicatorText:(NSString *)text;

@end
