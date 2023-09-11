//
//  CoronaLiveBuildFileManagerDelegateImpl.m
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
//

#import "CoronaLiveBuildFileManagerDelegateImpl.h"
#import "CoronaLiveBuildActivityIndicator.h"
#import <UIKit/UIKit.h>

@interface CoronaLiveBuildFileManagerDelegateImpl ()
{
@private
	UIViewController *_viewController;
	CoronaLiveBuildActivityIndicator *_activityIndicator;
}
@end


@implementation CoronaLiveBuildFileManagerDelegateImpl

- (id)initWithController:(UIViewController *)controller
{
	self = [super init];

	if ( self )
	{
		_viewController = controller;
		_activityIndicator = [[CoronaLiveBuildActivityIndicator alloc] init];
	}

	return self;
}

- (void)dealloc
{
	// Keep the activityView alive longer b/c _fileSync tear down will try to dismiss
	// the activity by calling back into this class via the delegate (hideActivityIndicator:)
	[_activityIndicator release];

	[super dealloc];
}

- (void)simulateCoronaCommand:(NSDictionary*)args
{
	if([_viewController.view respondsToSelector:@selector(simulateCommand:)])
	{
		[_viewController.view performSelector:@selector(simulateCommand:) withObject:args];
	}
}

- (void)runWithPath:(NSString *)projectPath
{
	if ( projectPath )
	{
		// Change CoronaView's resource directory

		// {
		//   ["command"] = "launch",
		//   ["options"] =
		//   {
		//     ["resourcePath"] = projectPath
		//   }
		// }
		NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"launch", @"command",
							  [NSDictionary dictionaryWithObject:projectPath forKey:@"resourcePath"], @"options",
							  nil];

		[self simulateCoronaCommand:args];
	}
}

- (void)relaunch
{
	// {
	//   ["command"] = "relaunch",
	// }
	NSDictionary *args = [NSDictionary dictionaryWithObject:@"relaunch" forKey:@"command"];

	[self simulateCoronaCommand:args];
}

-(void)setActivityIndicatorText:(NSString *)text
{
	[_activityIndicator setLabel:text];
}

- (void)filesWillSync
{
	[_activityIndicator show];
}

- (void)filesDidSync
{
	[_activityIndicator hide];
	[self relaunch];
}

@end
