// ----------------------------------------------------------------------------
//
//  CoronaLiveBuildActivityIndicator.h
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
// ----------------------------------------------------------------------------

#import <Foundation/NSObject.h>

// ----------------------------------------------------------------------------

@interface CoronaLiveBuildActivityIndicator : NSObject

- (void)show;
- (void)hide;

- (void)setLabel:(NSString *)newValue;

@end
