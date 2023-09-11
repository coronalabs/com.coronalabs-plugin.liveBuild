
//
//  CoronaLiveBuildFileManager.h
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
//

#import <Foundation/Foundation.h>

@class UIViewController;
@protocol CoronaFileManager;

FOUNDATION_EXTERN NSString * const CLSK_BasePath;
FOUNDATION_EXTERN NSString * const CLSK_ViewController;
FOUNDATION_EXTERN NSString * const CLSK_Key;
FOUNDATION_EXTERN NSString * const CLSK_IP;
FOUNDATION_EXTERN NSString * const CLSK_Port;
FOUNDATION_EXTERN NSString * const CLSK_Id;

@protocol CoronaFileManagerDelegate

-(void) filesWillSync;
-(void) filesDidSync;

@end

@protocol CoronaFileManager < NSObject >
@property (nonatomic, assign) id< CoronaFileManagerDelegate > delegate;

- (id)initWithParams:(NSDictionary*)params;

- (void)startSyncing;
- (void)stopSyncing;
- (void)resync;

@end
