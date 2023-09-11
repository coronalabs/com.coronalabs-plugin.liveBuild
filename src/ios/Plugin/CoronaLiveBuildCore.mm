// ----------------------------------------------------------------------------
//
//  CoronaLiveBuildCore.mm
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
// ----------------------------------------------------------------------------


#import <UIKit/UIKit.h>
#import "CoronaLiveBuildCore.h"


#import "CoronaLiveBuildFileManager.h"
#import "CoronaLiveBuildFileManagerLocal.h"
#import "CoronaLiveBuildFileManagerDelegateImpl.h"


// ----------------------------------------------------------------------------

// Strings used on UI
static NSString * const kCancel = @"Cancel";
static NSString * const kResetProject = @"Reset Project";
static NSString * const kRelaunch = @"Relaunch";


static UIViewController *
GetRoot( UIViewController *controller )
{
	UIViewController *result = controller;
	
	for ( controller = controller.parentViewController;  nil != controller; controller = controller.parentViewController )
	{
		result = controller;
	}
	
	return result;
}



// ------------------------------------------------------------------------------------------

@interface CoronaLiveBuildCore()
{
@private
	id< CoronaFileManager > _fileSync;
	UITapGestureRecognizer *_recognizer;
	UIViewController *_viewController;
}

@property (nonatomic, retain) CoronaLiveBuildFileManagerDelegateImpl* delegate;

+ (id< CoronaFileManager >)createFileSync:(UIViewController *)controller params:(NSDictionary*)params;

- (void)reset;

@end


@implementation CoronaLiveBuildCore

+ (id< CoronaFileManager >)createFileSync:(UIViewController *)controller params:(NSDictionary*)params
{
	NSMutableDictionary* newParams = [NSMutableDictionary dictionaryWithDictionary:params];

	[newParams setObject:[CoronaLiveBuildCore defaultPath] forKey:CLSK_BasePath];
	[newParams setObject:controller forKey:CLSK_ViewController];

	id< CoronaFileManager > result = [[CoronaLiveBuildFileManagerLocal alloc] initWithParams:newParams];
	
	return [result autorelease];
}


+ (NSString *)defaultPath
{
	NSString *sLocalRoot = nil;

#if not(TARGET_OS_TV)
	NSSearchPathDirectory directory = NSDocumentDirectory;
#else
	NSSearchPathDirectory directory = NSCachesDirectory;
#endif
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( directory, NSUserDomainMask, YES );
	NSString *documentsDirectory = [paths objectAtIndex:0];
	sLocalRoot = [documentsDirectory stringByAppendingPathComponent:@".CoronaLive"];

	// If it was removed somehow, create it
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	BOOL isDir = NO;
	if ( ! [fileMgr fileExistsAtPath:sLocalRoot isDirectory:& isDir] )
	{
		if ( ! isDir )
		{
			[fileMgr removeItemAtPath:sLocalRoot error:nil];
		}
		
		[fileMgr createDirectoryAtPath:sLocalRoot withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return sLocalRoot;
}

- (id)initWithController:(UIViewController *)controller
{
	self = [super init];
	
	if ( self )
	{

		_viewController = controller;
//		_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFourFingerGesture:)];
//		_recognizer.numberOfTouchesRequired = 4;
//		[_viewController.view addGestureRecognizer:_recognizer];

		_delegate = [[CoronaLiveBuildFileManagerDelegateImpl alloc] initWithController:controller];
		_fileSync = nil;
	}
	
	return self;
}


- (void)dealloc
{
	[_delegate release];
	_delegate = nil;

	if(_recognizer)
	{
		[_viewController.view removeGestureRecognizer:_recognizer];
		[_recognizer release];
		_recognizer = nil;
	}

	[_fileSync stopSyncing];
	[_fileSync release];
	_fileSync = nil;
	
	[super dealloc];
}

- (BOOL)isPhone
{
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

// We explicitly remove cancel buttons for iPads for iOS 7-,
// This conforms with Apple's Human Interface Guidelines, and also works-around a bug in iOS 7
// where the last button in the projects menu won't show up if there's a cancel button.
// However this causes another iOS 7 bug where the last button in the action sheet won't have a line seperating it from the previous one.
// Both buttons still work fine however, so we'll live with functional over aesthetically pleasing.
// iOS 7 bug with cancel button: http://stackoverflow.com/questions/7678518/ipad-uiactionsheet-not-displaying-the-last-added-button
// iOS 7 bug with seperators: http://stackoverflow.com/questions/18790868/uiactionsheet-is-not-showing-separator-on-the-last-item-on-ios-7-gm
// Human interface Guideline: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/UIKitUICatalog/UIActionSheet.html
- (NSString *)createCancelButtonTitle
{
	NSString *cancelButtonTitle = [self isPhone] ? kCancel : nil;
	return cancelButtonTitle;
}

#if not(TARGET_OS_TV)

- (void)presentAlertController:alertController
{
	// Based on: http://stackoverflow.com/questions/24224916/presenting-a-uialertcontroller-properly-on-an-ipad-using-ios-8
	[alertController setModalPresentationStyle:UIModalPresentationPopover];
	
	// From: http://stackoverflow.com/questions/24639082/keywindow-does-not-always-return-a-uiwindow
	UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
	
	UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
	popPresenter.sourceView = window;
	popPresenter.sourceRect = CGRectMake(window.center.x, window.bounds.size.height, 0, 0);
	
	[_viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)handleFourFingerGesture:(UIGestureRecognizer *)recognizer
{
	// UIActionSheet was deprecated in iOS 8.0, so create the main menu the new way
	if ( [UIAlertController class] )
	{
		UIAlertController* mainMenuController = [UIAlertController alertControllerWithTitle:nil
																	   message:nil
																preferredStyle:UIAlertControllerStyleActionSheet];
		
		// The cancel action won't show up as a button by default on iPads running iOS 8+
		// This is enforced by Apple and noted in their Human Interface Guidelines.
		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:kCancel style:UIAlertActionStyleCancel
															 handler:^(UIAlertAction * action) {}];
		UIAlertAction* resetProjectAction = [UIAlertAction actionWithTitle:kResetProject style:UIAlertActionStyleDestructive
															 handler:^(UIAlertAction * action) {
																 [self showResetProjectAlert];
															 }];
		UIAlertAction* relaunchAction = [UIAlertAction actionWithTitle:kRelaunch style:UIAlertActionStyleDefault
																   handler:^(UIAlertAction * action) {
																	   [self relaunch];
																   }];

		[mainMenuController addAction:cancelAction];
		[mainMenuController addAction:resetProjectAction];
		[mainMenuController addAction:relaunchAction];


		[self presentAlertController:mainMenuController];
	}
	else
	{
		// iOS7 adn 6 will call actionSheet:clickedButtonAtIndex:
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:[self createCancelButtonTitle]
												   destructiveButtonTitle:kResetProject
														otherButtonTitles:kRelaunch, nil];

		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		[actionSheet showInView:window];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( actionSheet.cancelButtonIndex == buttonIndex )
	{
		return;
	}else if ( actionSheet.destructiveButtonIndex == buttonIndex )
	{
		[self showResetProjectAlert];
	}
	else if ( actionSheet.firstOtherButtonIndex == buttonIndex )
	{
		// Relaunch
		[self relaunch];
	}
}

- (void)showResetProjectAlert
{
	NSString *t = @"Are you sure you want to reset the project?";
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:t
							  message:nil
							  delegate:self
							  cancelButtonTitle:kCancel
							  otherButtonTitles:@"Reset", nil];
	[alertView show];
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( 0 == buttonIndex )
	{
		// Cancelled
	}
	else if ( 1 == buttonIndex )
	{
		// Reset Project
		[self reset];
	}
}

#endif

- (void)relaunch
{
	[_delegate relaunch];
}

- (void)reset
{
	[_fileSync resync];
}

static NSString * const kLiveLastId = @".CoronaLive_id";


- (void)runWithParams:(NSDictionary*)params
{
	BOOL forceReset = NO;
#if TARGET_OS_TV
	NSString * path = [[NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) firstObject] stringByAppendingPathComponent:@".CoronaLive"];
	forceReset = ![[NSFileManager defaultManager] fileExistsAtPath:path];
#endif

	if(_fileSync == nil) {
		_fileSync = [[[self class] createFileSync:GetRoot(_viewController) params:params] retain];
		_fileSync.delegate = _delegate;
	}
	NSInteger thisId = [[params objectForKey:@"id"] integerValue];
	if(thisId != [[NSUserDefaults standardUserDefaults] integerForKey:kLiveLastId] || forceReset) {
		[_delegate setActivityIndicatorText:@"Initializing project..."];
		[self reset];
		[[NSUserDefaults standardUserDefaults] setInteger:thisId forKey:kLiveLastId];
	}
	else
	{
		[_fileSync startSyncing];
	}
	[_delegate runWithPath:[CoronaLiveBuildCore defaultPath]];
}


@end
