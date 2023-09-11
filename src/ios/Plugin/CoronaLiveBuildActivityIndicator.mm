// ----------------------------------------------------------------------------
//
//  CoronaLiveBuildActivityIndicator.mm
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
// ----------------------------------------------------------------------------

#import "CoronaLiveBuildActivityIndicator.h"

#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------

@interface CoronaLiveBuildActivityIndicator()
{
@private
	UIView *_activityView;
	UILabel *_label;
}

@end

// ----------------------------------------------------------------------------

static NSString * const kDefaultLabel = @"Syncing project...";

@implementation CoronaLiveBuildActivityIndicator

- (instancetype)init
{
	self = [super init];
	
	if ( self )
	{
		UIScreen *mainScreen = [UIScreen mainScreen];
		CGRect screenBounds = mainScreen.bounds; // includes status bar
		_activityView = [[UIView alloc] initWithFrame:screenBounds];
		_activityView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5f];
		_activityView.opaque = NO;
		_activityView.hidden = YES;

		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[_activityView addSubview:indicator];
		indicator.center = [_activityView convertPoint:_activityView.center fromView:_activityView.superview];
		[indicator startAnimating];
		[indicator release];

		_label = [[[UILabel alloc] initWithFrame:screenBounds] autorelease];
		_label.backgroundColor = [UIColor clearColor];
		_label.opaque = NO;
		_label.text = kDefaultLabel;
		_label.textColor = [UIColor whiteColor];
		_label.textAlignment = NSTextAlignmentCenter;
		[_activityView addSubview:_label];
		CGPoint center = [_activityView convertPoint:_activityView.center fromView:_activityView.superview];
		center.y += indicator.frame.size.height;
		_label.center = center;

		UIView *root = [UIApplication sharedApplication].keyWindow;
		[root addSubview:_activityView];
	}

	return self;
}

- (void)dealloc
{
	[_activityView removeFromSuperview];
	[_activityView release];

	[super dealloc];
}

- (void)show;
{
	if ( _activityView.hidden )
	{
		_activityView.hidden = NO;
		[[_activityView superview] bringSubviewToFront:_activityView];
	}
}

- (void)hide;
{
	if ( ! _activityView.hidden )
	{
		_activityView.hidden = YES;
	}
}

- (void)setLabel:(NSString *)newValue
{
	if ( ! newValue )
	{
		newValue = kDefaultLabel;
	}

	_label.text = newValue;
}

@end
