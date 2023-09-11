//
//  LuaLoader.java
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This corresponds to the name of the Lua library,
// e.g. [Lua] require "plugin.library"
package plugin.liveBuild;


import android.content.Context;

import java.io.File;
import java.io.FileInputStream;
import java.util.Timer;

import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaRuntimeListener;
import com.naef.jnlua.LuaState;

import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeProvider;

import com.ansca.corona.CoronaLiveBuildControllerAccessor;

public class CoronaLiveSync {

    private Context mContext;
    private Timer mTimer;
    private File mBaseDir;
    private SyncTask mSyncTask;

    public CoronaLiveSync(Context context, File baseDir) {
        mContext = context;
        mBaseDir = baseDir;
        mBaseDir.mkdirs();
        mTimer = new Timer();
        CoronaEnvironment.addRuntimeListener(new CoronaRuntimeEventHandler());
    }

    public void run(String id, String key, String ip, Integer port) {

        for(CoronaRuntime runtime : CoronaRuntimeProvider.getAllCoronaRuntimes()) {
            try {
                LuaState L = runtime.getLuaState();

                // TODO: figure this out
                // CoronaViewerControllerAccessor.setCoronaRuntimePath(runtime, mBaseDir.getAbsolutePath());

                L.getGlobal("package");
                L.pushString(mBaseDir.getAbsolutePath() + "/?.lua");
                L.setField(-2, "path");
                L.pop(1);

                File main = new File(mBaseDir, "main.lua");
                FileInputStream fis = new FileInputStream(main);
                L.load(fis, "main");
                L.call(0, 0);
            } catch (Exception e) {e.printStackTrace();}
        }

        mSyncTask = new SyncTask(mContext, mBaseDir, key, ip, port, id);
        mTimer.scheduleAtFixedRate(mSyncTask, 0, 3000);
    }


    private class CoronaRuntimeEventHandler implements CoronaRuntimeListener {
        @Override
        public void onLoaded(CoronaRuntime runtime) {}

        @Override
        public void onStarted(CoronaRuntime runtime) {}

        @Override
        public void onSuspended(CoronaRuntime runtime) {}

        @Override
        public void onResumed(CoronaRuntime runtime) {}

        @Override
        public void onExiting(CoronaRuntime runtime) {
            mSyncTask.StopSyncTask();
            mTimer.cancel();
            mTimer.purge();
            CoronaEnvironment.removeRuntimeListener(this);
        }
    }


}