// ----------------------------------------------------------------------------
//
//  CoronaLiveBuildCore.h
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
// ----------------------------------------------------------------------------

#import <Foundation/NSObject.h>
#import <UIKit/UIActionSheet.h>
#import <UIKit/UIAlertView.h>
#import "CoronaLiveBuildFileManager.h"

@class CoronaLiveBuildCore;

// ----------------------------------------------------------------------------

@interface CoronaLiveBuildCore : NSObject
#if not(TARGET_OS_TV)
 < UIActionSheetDelegate, UIAlertViewDelegate >
#endif 

@property (nonatomic, readonly) BOOL isRunning;

+ (NSString *)defaultPath;

- (id)initWithController:(UIViewController *)controller;

// Starts the syncing process.
- (void)runWithParams:(NSDictionary*)params;

@end
