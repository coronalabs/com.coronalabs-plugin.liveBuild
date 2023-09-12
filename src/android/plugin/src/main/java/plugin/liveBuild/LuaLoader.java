//
//  LuaLoader.java
//  TemplateApp
//
//  Copyright (c) 2012-2016 Corona Labs. All rights reserved.
//

// This corresponds to the name of the Lua library,
// e.g. [Lua] require "plugin.liveBuild"
package plugin.liveBuild;

import com.naef.jnlua.LuaState;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.NamedJavaFunction;

import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaLiveBuildControllerAccessor;
import com.ansca.corona.CoronaRuntimeProvider;

import com.ansca.corona.permissions.PermissionsServices;
import com.ansca.corona.permissions.PermissionsSettings;
import com.ansca.corona.permissions.PermissionState;
import com.ansca.corona.permissions.PermissionUrgency;

import android.content.Context;
import android.content.Intent;

public class LuaLoader implements JavaFunction {

	private CoronaLiveSync mSyncer;

	public static CoronaActivity getActivity() {
		CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
		if (activity == null) {
			for(CoronaRuntime runtime : CoronaRuntimeProvider.getAllCoronaRuntimes()) {
				Context c = CoronaLiveBuildControllerAccessor.getCoronaContext(runtime);
				if (c != null) {
					if (c instanceof CoronaActivity) {
						activity = (CoronaActivity)c;
						break;
					}
				}
			}
		}
		return activity;
	}


	public LuaLoader() {
		CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
		// Validate.
		if (activity == null) {
			throw new IllegalArgumentException("Activity cannot be null.");
		}

		if (LauncherService.sService == null) {
			activity.startService(new Intent(activity, LauncherService.class));
		}
	}

	/**
	 * Warning! This method is not called on the main UI thread.
	 */
	@Override
	public int invoke(LuaState L) {
        mSyncer = new CoronaLiveSync(LuaLoader.getActivity(), LuaLoader.getActivity().getFileStreamPath("coronaResources"));
		
		// Add functions to library
		NamedJavaFunction[] luaFunctions = new NamedJavaFunction[] {
			new RunWrapper(),
		};

		String libName = L.toString( 1 );
		L.register(libName, luaFunctions);

		return 1;
	}

	private class RunRequestPermissionsResultHandler implements CoronaActivity.OnRequestPermissionsResultHandler {

		final String id;
		final String key;
		final String ip;
		final Integer port;

		public RunRequestPermissionsResultHandler(String id, String key, String ip, Integer port) {
			this.id = id;
			this.key = key;
			this.ip = ip;
			this.port = port;
		}

		public void handleRun() {
			// Check for WRITE_EXTERNAL_STORAGE permission.
			PermissionsServices permissionsServices = new PermissionsServices(CoronaEnvironment.getApplicationContext());
			PermissionState writeExternalStoragePermissionState = permissionsServices.getPermissionStateFor(PermissionsServices.Permission.WRITE_EXTERNAL_STORAGE);
			switch(writeExternalStoragePermissionState) {
				case MISSING:
					run();
					break;
				case DENIED:
					// Only possible on Android 6.
					if (!permissionsServices.shouldNeverAskAgain(PermissionsServices.Permission.WRITE_EXTERNAL_STORAGE)) {
						// Create our Permissions Settings to compare against in the handler.
						PermissionsSettings settings = new PermissionsSettings(PermissionsServices.Permission.WRITE_EXTERNAL_STORAGE);
						settings.setUrgency(PermissionUrgency.CRITICAL);

						// Request Write External Storage permission.
						permissionsServices.requestPermissions(settings, this);
					} else {
						run();
					}
					break;
				default:
					// Permission is granted!
					run();
			}
		}

		@Override
		public void onHandleRequestPermissionsResult(CoronaActivity activity, int requestCode, String[] permissions, int[] grantResults) {
			PermissionsSettings permissionsSettings = activity.unregisterRequestPermissionsResultHandler(this);

			if (permissionsSettings != null) {
				permissionsSettings.markAsServiced();
			}

			// Check for WRITE_EXTERNAL_STORAGE permission.
			PermissionsServices permissionsServices = new PermissionsServices(activity);
			if (permissionsServices.getPermissionStateFor(PermissionsServices.Permission.WRITE_EXTERNAL_STORAGE) == PermissionState.GRANTED) {
				run();
			} else {

			}
		}

		private void run() {
            mSyncer.run(id, key, ip, port);
		}
	}

	private class RunWrapper implements NamedJavaFunction {
		@Override
		public String getName() {
			return "run";
		}

		@Override
		public int invoke(LuaState L) {
			int idx = 1;
			String key = null, ip = null, id = null;
			Integer port = null;
			if(L.isTable(idx)) {

				L.getField(idx, "key");
				if(L.isString(-1)) {
					key = L.toString(-1);
				}
				L.pop(1);

				L.getField(idx, "ip");
				if(L.isString(-1)) {
					ip = L.toString(-1);
				}
				L.pop(1);

				L.getField(idx, "id");
				if(L.isString(-1)) {
					id = L.toString(-1);
				}
				L.pop(1);

				L.getField(idx, "port");
				if(L.isNumber(-1)) {
					port = L.toInteger(-1);
				}
				L.pop(1);

			}

			RunRequestPermissionsResultHandler resultHandler = new RunRequestPermissionsResultHandler(id, key, ip, port);
			resultHandler.handleRun();
			return 0;
		}
	}


}