package com.ansca.corona;
import android.content.Context;

public class CoronaLiveBuildControllerAccessor {
	public static Context getCoronaContext(CoronaRuntime runtime) {
		Controller controller = runtime.getController();
		return controller.getContext();
	}

	public static void setCoronaRuntimePath(CoronaRuntime runtime, String path) {
		runtime.setPath(path);
	}
}
