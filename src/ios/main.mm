//
//  main.mm
//
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//

#import "CoronaApplicationMain.h"

#import "AppCoronaDelegate.h"

int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		CoronaApplicationMain( argc, argv, [AppCoronaDelegate class] );
	}

	return 0;
}
