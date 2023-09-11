// ----------------------------------------------------------------------------
//
//  CoronaLiveBuildLibrary.mm
// 
//  Copyright (c) 2016 Corona Labs. All rights reserved.
//  by Vlad Shcherban
//
// ----------------------------------------------------------------------------

#import "CoronaLiveBuildLibrary.h"

#import "CoronaLiveBuildCore.h"

#import <Foundation/Foundation.h>

#include "CoronaLibrary.h"
#include "CoronaRuntime.h"
#include "CoronaLuaObjCHelper.h"


static int LiveBuild_Finalizer( lua_State *L )
{
	CoronaLiveBuildCore* cv = (CoronaLiveBuildCore*)CoronaLuaToUserdata( L, 1 );
	[cv release];
	return 0;
}


static int LiveBuild_Run( lua_State *L )
{
	CoronaLiveBuildCore* cv = (CoronaLiveBuildCore*)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	[cv runWithParams:CoronaLuaCreateDictionary(L, 1)];
	return 0;
}


CORONA_EXPORT int luaopen_plugin_liveBuild( lua_State *L )
{
	id<CoronaRuntime> coronaRuntime = (id<CoronaRuntime>)CoronaLuaGetContext(L);
	UIViewController *viewController = coronaRuntime.appViewController;
	CoronaLiveBuildCore* core = [[CoronaLiveBuildCore alloc] initWithController:viewController];

	static const char kName[] = "plugin.liveBuild";
	static const char kMetatableName[] = __FILE__;
	const luaL_Reg kVTable[] =
	{
		{ "run", LiveBuild_Run },
		{ NULL, NULL }
	};

	CoronaLuaInitializeGCMetatable(L, kMetatableName, LiveBuild_Finalizer);
	CoronaLuaPushUserdata( L, core, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 );

	return 1;
}
