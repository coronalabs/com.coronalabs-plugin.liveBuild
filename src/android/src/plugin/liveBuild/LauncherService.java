package plugin.liveBuild;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;
import android.content.Context;

import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaLiveBuildControllerAccessor;
import com.ansca.corona.CoronaRuntimeProvider;

public class LauncherService extends Service {
    public static LauncherService sService;

    private Timer mTimer;

    @Override
    public void onCreate() {
        sService = this;
        mTimer = new Timer();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public void relaunch() {
        finishActivities();

        try {
            java.lang.reflect.Field f = com.ansca.corona.graphics.FontServices.class.getDeclaredField("sTypefaceCollection");
            f.setAccessible(true);
            java.util.HashMap sTypefaceCollection = (java.util.HashMap)f.get(null);
            synchronized (sTypefaceCollection) {
                sTypefaceCollection.clear();
            }
        } catch (Exception e) {
        }

        mTimer.schedule(new TimerTask() {
            public void run() {
                Intent intent = new Intent(sService, com.ansca.corona.CoronaActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        }, 1000);
    }

    public static void finishActivities() {
        CoronaActivity activity;
        for(CoronaRuntime runtime : CoronaRuntimeProvider.getAllCoronaRuntimes()) {
            Context c = CoronaLiveBuildControllerAccessor.getCoronaContext(runtime);
            if (c != null) {
                if (c instanceof CoronaActivity) {
                    activity = (CoronaActivity)c;
                    activity.finish();
                }
            }
        }
    }
}

