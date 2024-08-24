package plugin.liveBuild;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.system.Os;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimerTask;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;


class SyncTask extends TimerTask {

    static private byte[] sslCertificate = new byte[]{ 48,-126,3,80,48,-126,2,56,2,9,0,-92,-62,100,-106,121,67,-11,-18,48,13,6,9,42,-122,72,-122,-9,13,1,1,11,5,0,48,105,49,11,48,9,6,3,85,4,6,19,2,85,83,49,19,48,17,6,3,85,4,8,19,10,67,97,108,105,102,111,114,110,105,97,49,18,48,16,6,3,85,4,7,19,9,80,97,108,111,32,65,108,116,111,49,20,48,18,6,3,85,4,10,19,11,67,111,114,111,110,97,32,76,97,98,115,49,27,48,25,6,3,85,4,11,19,18,67,111,114,111,110,97,32,76,105,118,101,32,83,101,114,118,101,114,48,32,23,13,49,54,49,48,49,52,49,53,48,54,49,52,90,24,15,50,48,53,48,48,49,48,49,49,53,48,54,49,52,90,48,105,49,11,48,9,6,3,85,4,6,19,2,85,83,49,19,48,17,6,3,85,4,8,19,10,67,97,108,105,102,111,114,110,105,97,49,18,48,16,6,3,85,4,7,19,9,80,97,108,111,32,65,108,116,111,49,20,48,18,6,3,85,4,10,19,11,67,111,114,111,110,97,32,76,97,98,115,49,27,48,25,6,3,85,4,11,19,18,67,111,114,111,110,97,32,76,105,118,101,32,83,101,114,118,101,114,48,-126,1,34,48,13,6,9,42,-122,72,-122,-9,13,1,1,1,5,0,3,-126,1,15,0,48,-126,1,10,2,-126,1,1,0,-46,-31,-77,26,-84,-123,117,104,15,-30,15,31,78,-17,-71,50,-90,-118,-3,101,54,5,-75,50,-37,-83,-17,-124,88,-55,82,64,124,124,-54,15,76,-68,-84,-53,-20,-57,-42,-98,30,111,-34,-19,-42,-52,-13,-47,35,109,-25,-107,112,-24,112,-21,58,110,83,101,18,31,61,86,-5,-67,-43,65,127,-3,-32,74,-111,-64,53,5,-116,21,-5,18,85,-116,-42,103,70,6,-67,51,32,18,69,-3,-89,127,85,-100,120,88,8,-9,5,-49,118,111,29,82,-2,12,-16,49,10,-106,-100,0,77,65,-122,126,-37,1,-100,16,104,-117,-123,-18,-86,-88,-63,-64,-98,-115,18,8,-71,64,81,-83,78,87,53,-45,-87,110,24,-18,26,-69,6,56,-13,-114,-67,92,-45,93,-64,-11,-52,-48,-22,65,120,-92,80,124,-72,32,-90,115,14,-11,-39,-20,-64,67,63,-68,27,-48,98,-15,37,38,-39,-9,119,-87,83,-71,77,126,-35,-52,82,40,-82,119,-31,92,47,36,-67,-73,-118,-4,10,92,-40,-77,66,-103,-1,-45,-109,-41,81,-77,-33,114,-89,52,-58,72,20,28,93,27,17,-42,-125,-56,-121,52,-23,-45,-104,-49,-95,112,40,-10,27,112,104,103,-52,-71,-81,-113,-55,-115,2,3,1,0,1,48,13,6,9,42,-122,72,-122,-9,13,1,1,11,5,0,3,-126,1,1,0,-123,-112,44,124,-42,-127,16,117,-41,13,-62,-80,-10,5,-84,-16,108,24,-64,19,68,9,26,-56,-119,44,-28,53,45,122,-104,-49,36,117,73,-9,109,-7,-24,58,79,125,4,-25,-69,97,56,-113,73,60,-88,92,-73,54,-128,-29,119,-59,-119,-84,7,-95,110,-114,-76,-123,-92,14,58,24,-60,92,112,25,-89,65,-105,-127,-96,73,-45,83,63,-7,-117,-7,66,-22,105,23,53,-99,40,-91,81,-25,-91,118,-41,-73,67,-51,-68,-93,101,97,77,-116,21,-9,2,33,-102,-53,107,69,-105,-37,50,-4,-104,110,-91,-21,-25,86,11,35,-5,18,36,-85,-28,109,-42,-25,25,-59,30,2,109,-49,64,-40,57,44,40,-65,-58,62,-17,-87,-114,-7,64,-112,-92,115,-33,80,-41,58,-14,85,54,5,-120,118,109,57,-118,98,-55,124,93,-75,39,35,86,17,66,-111,-127,-1,85,50,99,33,-109,86,-94,127,-69,-93,-85,-98,-14,-75,66,7,-38,36,37,-58,70,55,1,48,56,-45,-65,-28,-89,101,66,23,-110,60,117,-20,-12,-57,-4,-33,116,98,10,36,93,-108,24,-81,32,113,-45,66,-46,54,82,-84,20,124,-122,88,91,107,38,113,-112,-84,-49,2,-22,-41,-42,-19};

    static private SSLSocketFactory sSocketFactory = null;
    static private SSLSocketFactory SocketFactory() {
        if(sSocketFactory == null) {
            try {
                CertificateFactory cf = CertificateFactory.getInstance("X.509");
                Certificate cert = cf.generateCertificate(new ByteArrayInputStream(sslCertificate));
                KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
                keyStore.load(null, null);
                keyStore.setCertificateEntry("cert", cert);
                TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
                tmf.init(keyStore);
                SSLContext context = SSLContext.getInstance("TLS");
                context.init(null, tmf.getTrustManagers(), null);
                sSocketFactory = context.getSocketFactory();
            } catch (Exception e) {
                e.printStackTrace();
            }

        }
        return sSocketFactory;
    }

    private static HostnameVerifier HOSTNAME_ALL = new HostnameVerifier() {
        @SuppressLint("BadHostnameVerifier")
        @Override
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    };


    private static final String PREFERENCE_FILE = "_LiveBuildPrefs_";
    private static final String PREF_INSTALL_ID = "InstallId";
    private static final String PREF_LAST_SERVER_RING= "LastServerRing";

    private static final int MAX_RING_SIZE = 3;
    private static final int SERVER_CHECK_TIMEOUT_QUICK = 4000;
    private static final int SERVER_CHECK_TIMEOUT = 13000;
    private static final int SERVER_CONNECT_TIMEOUT = 14000;


    private static final String ANDROID_IS_TOO_OLD = "TooOldDialogShown";

    private boolean isCancelled = false;
    void StopSyncTask() {
        isCancelled = true;
        sRunning = false;
        if(mServerDiscoverer != null) {
            mServerDiscoverer.StopDiscoverer();
        }
    }

    private static class FileProps {
        long mod;
        long size;
        FileProps(long m, long s) {mod = m; size = s;}
        @Override
        public String toString() {
            return "FileProps [mod=" + mod + ", size=" + size + "]";
        }
    }

    private Context mContext;

    private Handler mHandler;

    private File mBaseDir;

    private Long mLastUpdate;
    private String mServerKey, mServerIP, mServerIPConfig;
    private Integer mServerPort, mServerPortConfig;
    private String mBuildId;

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private static class ServerDiscoverer {
        private final Object mSyncObject = new Object();
        private final SyncTask mSyncer;
        private final LinkedList<String> mServerRing;

        private boolean mStop = false;
        private NsdManager mNsdManager;
        private NsdManager.DiscoveryListener mDiscoveryListener;

        private class ServiceDiscoveryListener implements NsdManager.DiscoveryListener {

            @Override
            public void onStartDiscoveryFailed(String serviceType, int errorCode) {
                Log.w("LiveBuild", "Failed to start service discovery!");
                sRunning = false;
            }

            @Override
            public void onServiceFound(NsdServiceInfo serviceInfo) {
                if(mNsdManager!=null && !mStop) {
                    mNsdManager.resolveService(serviceInfo, new NsdManager.ResolveListener() {
                        @Override
                        public void onServiceResolved(NsdServiceInfo serviceInfo) {
                            String server = serviceInfo.getHost().getHostAddress();
                            Integer port = serviceInfo.getPort();
                            Log.i("LiveBuild", "Discovered server " + server + ":" + port);
                            ServerDiscovered(server, port);
                        }
                        @Override public void onResolveFailed(NsdServiceInfo serviceInfo, int errorCode) {}
                    });
                }
            }

            @Override
            public void onServiceLost(NsdServiceInfo serviceInfo) {}
            @Override
            public void onStopDiscoveryFailed(String serviceType, int errorCode) {}
            @Override
            public void onDiscoveryStarted(String serviceType) {}
            @Override
            public void onDiscoveryStopped(String serviceType) {}

        }

        ServerDiscoverer(SyncTask syncer) {
            mSyncer = syncer;

            SharedPreferences pref = mSyncer.mContext.getSharedPreferences(PREFERENCE_FILE, 0);
            mServerRing = new LinkedList<String>();
            mServerRing.addAll(Arrays.asList(pref.getString(PREF_LAST_SERVER_RING, "").split(";")));

            if(mServerRing.size() > 0) {
                String[] serverArr = mServerRing.getFirst().split(":");
                if (serverArr.length == 2) {
                    String server = serverArr[0];
                    Integer port = Integer.valueOf(serverArr[1]);
                    if(server != null && port != null) {
                        if(mSyncer.checkServer(server, port, SERVER_CHECK_TIMEOUT_QUICK)) {
                            StopDiscoverer();

                            mSyncer.mServerIP = server;
                            mSyncer.mServerPort = port;
                            mSyncer.ScheduleSync();

                            return;
                        }
                    }
                }
            }

            for (String serverString: mServerRing) {
                String[] serverArr = serverString.split(":");
                if (serverArr.length == 2) {
                    final String server = serverArr[0];
                    final Integer port = Integer.valueOf(serverArr[1]);
                    if(server != null && port != null) {
                        Thread checker = new Thread(new Checker(server, port, serverString));
                        checker.start();
                    }
                }
            }

            mNsdManager = (NsdManager) mSyncer.mContext.getSystemService(Context.NSD_SERVICE);
            mDiscoveryListener = new ServiceDiscoveryListener();
            mNsdManager.discoverServices("_corona_live._tcp.", NsdManager.PROTOCOL_DNS_SD, mDiscoveryListener);
        }

        void StopDiscoverer() {
            synchronized (mSyncObject) {
                mStop = true;
                if (mNsdManager != null) {
                    mNsdManager.stopServiceDiscovery(mDiscoveryListener);
                    mNsdManager = null;
                    mDiscoveryListener = null;
                }
                if(mSyncer.mServerDiscoverer == this) {
                    mSyncer.mServerDiscoverer = null;
                }
            }
        }

        void PrependServerRing(String addToFront) {
            mServerRing.removeFirstOccurrence(addToFront);
            mServerRing.addFirst(addToFront);

            while (mServerRing.size() > MAX_RING_SIZE ) {
                mServerRing.removeLast();
            }

            SharedPreferences.Editor editor = mSyncer.mContext.getSharedPreferences(PREFERENCE_FILE, 0).edit();
            String newRing = TextUtils.join(";", mServerRing);
            editor.putString(PREF_LAST_SERVER_RING, newRing);
            editor.apply();
        }

        void ServerDiscovered(String server, Integer port) {
            final String serverString = server + ":" + port;
            synchronized (mSyncObject) {
                if (mStop) {
                    return;
                }
                PrependServerRing(serverString);
                Thread justDiscovered = new Thread(new Checker(server, port, serverString));
                justDiscovered.setPriority(Thread.NORM_PRIORITY+1);
                justDiscovered.start();
            }
        }


        private class Checker implements Runnable {

            final String server;
            final Integer port;
            final String serverString;
            Checker(String server, Integer port, String serverString) {
                this.server = server;
                this.port = port;
                this.serverString = serverString;
            }

            @Override
            public void run() {
                if(mStop) {
                    return;
                }

                boolean serverCheck = mSyncer.checkServer(server, port);

                synchronized (mSyncObject) {
                    if(mStop) {
                        return;
                    }

                    if(serverCheck) {
                        StopDiscoverer();

                        PrependServerRing(serverString);

                        mSyncer.mServerIP = server;
                        mSyncer.mServerPort = port;
                        mSyncer.ScheduleSync();
                        return;
                    }
                }

                try {
                    Thread.sleep(3142); // this is arbitrary number to sleep between request so we don't spam them. Also, it's PI*1000 for no reason.
                } catch (InterruptedException ignored) {}

                synchronized (mSyncObject) {
                    if(!mStop && mServerRing.contains(serverString)) {
                        new Thread(new Checker(server, port, serverString)).start();
                    }
                }
            }
        }

    }

    private ServerDiscoverer mServerDiscoverer;

    private static volatile boolean sRunning = false;

    private URLConnection getUrl(String method) throws IOException {
        return getUrl(method, null);
    }

    private URLConnection getUrl(String method, Map<String, String> params) throws IOException {
        return getUrl(mServerIP, mServerPort, method, params);
    }

    private URLConnection getUrl(String server, Integer port,String method, Map<String, String> params) throws IOException {
        if(params==null) params = new HashMap<String, String>();

        if(!params.containsKey("key")) {
            params.put("key", mServerKey);
        }

        StringBuilder sb = new StringBuilder("https://");
        sb.append(server).append(':').append(port).append('/').append(method).append('?');

        for (Map.Entry<String, String> entry : params.entrySet()) {
            sb.append(entry.getKey()).append('=').append(entry.getValue()).append('&');
        }
        sb.setLength(sb.length() - 1);

        URL url = new URL(sb.toString());
        HttpsURLConnection connection = (HttpsURLConnection)url.openConnection();
        connection.setSSLSocketFactory(SocketFactory());
        connection.setHostnameVerifier(HOSTNAME_ALL);
        connection.setConnectTimeout(SERVER_CONNECT_TIMEOUT);

        return connection;
    }

    SyncTask(Context context, File baseDir, String key, String ip, Integer port, String id) {
        mContext = context.getApplicationContext();
        mHandler = new Handler(Looper.getMainLooper());

        mServerDiscoverer = null;

        mServerIPConfig = ip;
        mServerPortConfig = port;
        mServerKey = key;
        mBuildId = id;

        mBaseDir = baseDir;
        if(mBaseDir.exists() && !mBaseDir.isDirectory())
            if(!mBaseDir.delete()) Log.e("LiveBuild", "Base directory error!");
        if(!mBaseDir.exists())
            if(!mBaseDir.mkdirs()) Log.e("LiveBuild", "Error while creating base directory!");

    }

    private static String ReadLink(File path) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                String ret = Os.readlink(path.getAbsolutePath());
                if(ret.isEmpty()) {
                    return null;
                } else {
                    return ret;
                }
            } catch (Exception ignored) {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    private static boolean sSymlinkWarningShown = false;
    private static boolean sCanCreateLinks = Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP;
    private final static boolean CanCreateLinks() {
        return sCanCreateLinks;
    }

    private static boolean CreateLink(File link, String dest) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                Os.symlink(dest, link.getAbsolutePath());
            } catch (Exception e) {
                Log.e("LiveBuild", "Error while creating symlink. Symlinks are disabled.", e);
                sCanCreateLinks = false;
                return false;
            }
        }
        else
        {
            return false;
        }
        return true;
    }

    private static HashMap<String, FileProps> ListExisting(File path, List<String> dirs, Map<String, String> symlinks,File baseDir) {
        HashMap<String, FileProps> ret = new HashMap<String, FileProps>();
        if (path.isDirectory()) {
            for (File f : path.listFiles()) {
                String dir = f.getAbsolutePath().substring(baseDir.getAbsolutePath().length());
                String linkDest = ReadLink(f);
                if(linkDest!=null) {
                    symlinks.put(dir, linkDest);
                } else if (f.isDirectory()) {
                    dirs.add(dir + '/');
                    ret.putAll(ListExisting(f, dirs, symlinks, baseDir));
                } else {
                    ret.put(dir, new FileProps(f.lastModified()/1000L, f.length()));
                }

            }
        }
        return ret;
    }

    private static void WriteLiveFile(File baseDir, InputStream is, String filePath, Long modDate)
    {
        File toUpdate = new File(baseDir, filePath);
        File parent = toUpdate.getParentFile();
        if(parent != null && !parent.exists())
            if(!parent.mkdirs()) Log.e("LiveBuild", "Error while creating folder containing " + toUpdate.toString());

        OutputStream os = null;

        try {
            os = new FileOutputStream(toUpdate);

            byte[] b = new byte[2048];
            int length;

            while ((length = is.read(b)) != -1) {
                os.write(b, 0, length);
            }

            if (!toUpdate.setLastModified(modDate*1000L)) {
                Log.w("LiveBuild", "Unable to set date for file:" + filePath);
            }
        } catch (IOException ignore) {
            Log.e("LiveBuild", "Error while writing file " + filePath);
        }
        finally {
            try {
                is.close();
                if(os!=null)
                    os.close();
            } catch (IOException ignore){}
        }
    }

    private static HashMap<String, String> sHashCache= new HashMap<String, String>();
    private String sha256(String string)
    {
        String result = sHashCache.get(string);
        if(result!=null) {
            return result;
        }

        MessageDigest digest;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            Log.e("LiveBuild", "Fatal error, no SHA-256 algorithm!", e);
            return string;
        }
        digest.update(string.getBytes());
        byte[] digestBytes = digest.digest();
        StringBuilder digestBuilder = new StringBuilder(digestBytes.length*2);
        for (byte digestByte : digestBytes) {
            String entry = String.format("%02x", digestByte);
            digestBuilder.append(entry);
        }
        result = digestBuilder.toString();
        sHashCache.put(string, result);
        return result;
    }

    private boolean checkServer(String server, Integer port, int timeout)
    {
        boolean res = false;
        try {
            HashMap<String, String> props = new HashMap<String, String>();
            props.put("key", sha256(mServerKey + "^eC*4K1ButGpA1Q8"));
            URLConnection connection = getUrl(server, port, "", props);
            connection.setReadTimeout(timeout);
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String response = in.readLine();
            in.close();
            res = response.equals(sha256(mServerKey + "C@!GEB@v2tLN_CG$e"));
        } catch (Exception ignored){
//            Log.i("CoronaLive","Failed to check ring server " + server + ":" + port);
        }
        return res;
    }

    private boolean checkServer(String server, Integer port)
    {
        return checkServer(server, port, SERVER_CHECK_TIMEOUT);
    }

    private static AlertDialog currentDialog = null;

    @Override
    public void run() {
        if (sRunning) {
            return;
        }
        sRunning = true;

        mServerIP = mServerIPConfig;
        mServerPort = mServerPortConfig;
        boolean manifestExists = false;
        try {
            LuaLoader.getActivity().getAssets().open("_corona_live_build_manifest.txt").close();
            manifestExists = true;
        } catch (Throwable ignore) {}
        final SharedPreferences prefs = mContext.getSharedPreferences(PREFERENCE_FILE, 0);
        String installId = prefs.getString(PREF_INSTALL_ID, null);
        File mainLua = new File(mBaseDir, "main.lua");
        if(manifestExists && (installId == null || !installId.equals(mBuildId)  || !mainLua.exists())) {
            SharedPreferences.Editor e = prefs.edit();
            e.putString(PREF_INSTALL_ID, mBuildId);
            e.apply();
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    final ResyncTask task = new ResyncTask(mBaseDir);
                    task.execute();
                }
            });
        }
        else if(mServerPort!=null && mServerIP!=null && mServerKey != null) {
            if(checkServer(mServerIP, mServerPort)) {
                ScheduleSync();
            } else {
                sRunning = false;
            }
        }
        else if(mServerKey != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                mServerDiscoverer = new ServerDiscoverer(this);
            } else {
                if(!prefs.getBoolean(ANDROID_IS_TOO_OLD, false) && currentDialog == null) {
                    LuaLoader.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            currentDialog = new AlertDialog.Builder(LuaLoader.getActivity()).create();
                            currentDialog.setTitle("Live Build discovery is unavailable");
                            currentDialog.setMessage("Automatic discovery of Live Build Server requires Android 4.1.\nAs a workaround, manually configure IP and Port in the '.CoronaLiveBuild' file in the project and rebuild the app.");
                            currentDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    SharedPreferences.Editor e = prefs.edit();
                                    e.putBoolean(ANDROID_IS_TOO_OLD, true);
                                    e.apply();
                                    dialog.dismiss();
                                    currentDialog = null;
                                }
                            });
                            currentDialog.show();
                        }
                    });
                }
                Log.e("LiveBuild", "Service discovery is available starting with Android v4.1 Jelly Bean, API level 16. You will need to use a newer Android device or set up a static IP address and port.");
            }
        } else {
            Log.e("LiveBuild", "Invalid configuration. No server or key present.");
            sRunning = true; // this will prevent attempts to start again...
        }
    }

    private static class ExcludeMatcher
    {
        private static ExcludeMatcher instance = null;
        static boolean Check(String path) {
            if(instance == null) instance = new ExcludeMatcher();
            return instance.include(path);
        }

        private List<String> excludePatterns = new LinkedList<String>();
        private AntPathMatcher pm = new AntPathMatcher();

        private ExcludeMatcher()
        {
            Context context = LuaLoader.getActivity();
            pm.setCachePatterns(true);

            BufferedReader reader = null;
            try {
                reader = new BufferedReader(new InputStreamReader(context.getAssets().open("_corona_live_build_exclude.txt"), "UTF-8"));
                String line;
                while ((line = reader.readLine()) != null) {
                    if(!line.isEmpty()) {
                        excludePatterns.add(line);
                    }
                }
            } catch (IOException ignored) {}
            finally {
                if (reader != null) {
                    try {
                        reader.close();
                    } catch (IOException ignored) {}
                }
            }
        }

        private boolean exclude(String fullPath) {
            if(fullPath == null || fullPath.isEmpty())
                return true;

            String path = fullPath.substring(1);
            for(String p : excludePatterns) {
                if(pm.match(p, path))
                    return true;
            }
            return false;
        }

        private boolean include(String path) {
            return !exclude(path);
        }
    }

    private class LongPollTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected Void doInBackground(Void... params) {
            if(!sRunning || isCancelled() || isCancelled)
                return null;

            try {
                HashMap<String, String> props = new HashMap<String, String>();
                props.put("modified", mLastUpdate.toString());
                URLConnection connection = getUrl("update", props);
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));

                String inputLine = in.readLine();
                in.close();

                if(sRunning && Long.parseLong(inputLine) > mLastUpdate && !isCancelled) {
                    ScheduleSync();
                    return null;
                }
            }
            catch (Exception ignored) {}

            if(sRunning && checkServer(mServerIP, mServerPort)) {
                ScheduleLongPoll();
            } else {
                sRunning = false;
            }
            return null;
        }
    }

    private void ScheduleLongPoll() {
        if(sRunning && !isCancelled) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    new LongPollTask().execute();
                }
            });
        }
    }

    private void ScheduleSync() {
        if(mServerDiscoverer != null) {
            mServerDiscoverer.StopDiscoverer();
        }

        final File dir = mBaseDir;

        List<String> statusDirs = new LinkedList<String>();
        Map<String, FileProps> statusFiles = new HashMap<String, FileProps>();
        Map<String, String> statusSymlinks = new HashMap<String, String>();

        try {
            mLastUpdate = ParseStatus(getUrl("status").getInputStream(), statusDirs, statusFiles, statusSymlinks,true);
        } catch (IOException e) {
            Log.e("LiveBuild", "Error while syncing with server", e);
            mLastUpdate = 0L;
        }

        if(mLastUpdate <= 0) {
            sRunning = false;
            return;
        }

        List<String> existingDirs= new LinkedList<String>();
        Map<String, String> existingSymlinks = new HashMap<String, String>();
        Map<String, FileProps> existingFiles = ListExisting(dir, existingDirs, existingSymlinks, dir);

        Set<String> dirsToDeleteSet = new HashSet<String>(existingDirs);
        dirsToDeleteSet.removeAll(statusDirs);

        Set<String> dirsToCreateSet = new HashSet<String>(statusDirs);
        dirsToCreateSet.removeAll(existingDirs);

        final List<String> filesToDelete = new LinkedList<String>();
        final List<Map.Entry<String, Long>> filesToDownload = new LinkedList< Map.Entry<String,Long>>();
        final List<String> dirsToCreate = new LinkedList<String>();
        final List<String> dirsToDelete = new LinkedList<String>();
        final Map<String, String> symlinksToCreate = new HashMap<String, String>();

        for(String f : existingFiles.keySet()) {
            if(!statusFiles.containsKey(f)) {
                filesToDelete.add(f);
            }
        }

        boolean configurationChange = false;

        for (Map.Entry<String, FileProps> e : statusFiles.entrySet()) {
            String file = e.getKey();
            FileProps existingProps = existingFiles.get(file);
            FileProps statusProps = e.getValue();
            if(existingProps == null || statusProps.mod != existingProps.mod || statusProps.size != existingProps.size) {
                if(ExcludeMatcher.Check(file)) {
                    filesToDownload.add(new AbstractMap.SimpleEntry<String, Long>(file, statusProps.mod));
                    configurationChange = configurationChange || file.equals("/build.settings") || file.equals("/config.lua");
                }
            }
        }

        dirsToCreate.addAll(dirsToCreateSet);
        Collections.sort(dirsToCreate);

        dirsToDelete.addAll(dirsToDeleteSet);
        Collections.sort(dirsToDelete);
        Collections.reverse(dirsToDelete);

        for (Map.Entry<String, String> e : existingSymlinks.entrySet()) {
            String statusDest = statusSymlinks.get(e.getKey());
            if(statusDest == null || !statusDest.equals(e.getValue())) {
                filesToDelete.add(e.getKey());
            }
        }

        for (Map.Entry<String, String> e : statusSymlinks.entrySet()) {
            String existingLink = existingSymlinks.get(e.getKey());
            if(existingLink == null || !existingLink.equals(e.getValue())) {
                symlinksToCreate.put(e.getKey(), e.getValue());
            }
        }

        int linksToCreate = symlinksToCreate.size();
        if(configurationChange) {
            LuaLoader.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(mContext, "Configuration Change Detected\nTo properly reflect changes in 'build.settings' or 'config.lua' you may need to rebuild the app.", Toast.LENGTH_LONG ).show();
                }
            });
        } else if(linksToCreate>0 && !CanCreateLinks() && !sSymlinkWarningShown) {
            sSymlinkWarningShown = true;
            LuaLoader.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(mContext, "Error while synchronizing symlinks. Symlinks synchronization is now disabled.", Toast.LENGTH_LONG ).show();
                }
            });
        }

        if(!CanCreateLinks()) {
            linksToCreate = 0;
        }

        // TODO: Consider parsing the compressed resource.car directly from the apk to remove this
        //       exception. The Android part of Solar2D uses mmap to load the unzipped resource.car,
        //       whose location overlaps with mBaseDir, causing the update to be triggered.
        filesToDelete.remove("/resource.car");

        int numUpdates = filesToDelete.size() + filesToDownload.size() + dirsToCreate.size() + dirsToDelete.size() + linksToCreate;

        if (numUpdates > 0) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    final AsyncSync async = new AsyncSync(dir, dirsToDelete, dirsToCreate, filesToDelete, symlinksToCreate, filesToDownload);
                    async.execute();
                }
            });
        } else {
            ScheduleLongPoll();
        }
    }

    private static Long ParseStatus(InputStream inputStream, List<String> statusDirs, Map<String, FileProps> statusFiles, Map<String, String> statusSymlinks, boolean lastUpdate) {
        Long ret = null;

        BufferedReader in = null;

        try {
            in = new BufferedReader(new InputStreamReader(inputStream));

            String inputLine;
            if (lastUpdate) {
                inputLine = in.readLine();
                if (inputLine != null) {
                    String[] parts = inputLine.split(" / ");
                    if (parts.length > 0) {
                        ret = Long.parseLong(parts[0]);
                    }
                }
            }

            StringBuilder sb = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                sb.append(inputLine);
            }

            in.close();


            String[] statusEntries = sb.toString().split(" //");
            for (String statusEntryLine : statusEntries) {
                String[] parts = statusEntryLine.split(" / ");
                if (parts.length == 3) {
                    String name = parts[2];
                    if (name.endsWith("/")) {
                        statusDirs.add(name);
                    } else {
                        statusFiles.put(name, new FileProps(Long.parseLong(parts[1]), Long.parseLong(parts[0])));
                    }
                } else if (statusEntryLine.startsWith("S&")){
                    parts = statusEntryLine.split("&");
                    if(parts.length != 3) {
                        continue;
                    }
                    String link = URLDecoder.decode(parts[1], "UTF-8");
                    String dest = URLDecoder.decode(parts[2], "UTF-8");
                    statusSymlinks.put(link, dest);
                }
            }
        }
        catch (IOException e) {
            Log.e("LiveBuild", "Error while parsing status", e);
        }
        finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException ignored) {}
            }

        }
        return ret;
    }

    private static class ResyncTask extends AsyncTask<Void, Void, Void> {
        private File baseDir;
        private ProgressDialog mProgress;

        ResyncTask(File baseDir) {
            this.baseDir = baseDir;
        }

        @Override
        protected void onPreExecute() {
            Context context = LuaLoader.getActivity();

            if (context == null) {
                return;
            }
            mProgress = ProgressDialog.show(context, "Initializing...", "Please wait");
        }

        private static void deleteRecursive(File fileOrDirectory) {
            if (fileOrDirectory.isDirectory())
                for (File child : fileOrDirectory.listFiles())
                    deleteRecursive(child);

            if(!fileOrDirectory.delete()) Log.e("LiveBuild", "Unable to delete directory " + fileOrDirectory.toString());
        }

        @Override
        protected Void doInBackground(Void... voids) {
            Context context = LuaLoader.getActivity();
            if (context == null)
                return null;

            List<String> dirs = new LinkedList<String>();
            Map<String, FileProps> files = new HashMap<String, FileProps>();

            try {
                ParseStatus(context.getAssets().open("_corona_live_build_manifest.txt"), dirs, files, new HashMap<String, String>(), false);
            } catch (IOException ignored) {
            }

            deleteRecursive(baseDir);
            if (!baseDir.mkdir())
                Log.e("LiveBuild", "Unable to create base directory " + baseDir.toString());

            for (String d : dirs) {
                File toCreate = new File(baseDir + d);
                if(!toCreate.exists())
                    if(!toCreate.mkdirs()) Log.e("LiveBuild", "Error while creating directory " + d);
            }

            for (Map.Entry<String, FileProps> fpe : files.entrySet()) {
                try {
                    String srcPath = "corona_live_build_app_" + fpe.getKey();
                    InputStream is = context.getAssets().open(srcPath);
                    WriteLiveFile(baseDir, is, fpe.getKey(), fpe.getValue().mod);
                } catch (IOException ignore) {
                }
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void params) {
            sRunning = false;
            mProgress.dismiss();
            LauncherService.sService.relaunch();
        }
    }


    private class AsyncSync extends AsyncTask<Void, Void, Void> {
        private final List<String> dirsDelete, dirsCreate, filesDelete;
        private final List<Map.Entry<String,Long>> filesUpdate;
        private final Map<String, String> symlinksToCreate;
        private final File baseDir;
        private ProgressDialog mProgress;

        AsyncSync(File baseDir, List<String> dirsDelete, List<String> dirsCreate, List<String> filesDelete, Map<String, String> symlinksToCreate, List<Map.Entry<String, Long>> filesToDownload) {
            this.dirsCreate = dirsCreate;
            this.dirsDelete = dirsDelete;
            this.filesDelete = filesDelete;
            this.filesUpdate = filesToDownload;
            this.baseDir = baseDir;
            this.symlinksToCreate = symlinksToCreate;
        }

        @Override
        protected void onPreExecute() {
           Context context = LuaLoader.getActivity();
            // Context context = mContext;

            if (context == null) {
                return;
            }
            mProgress = ProgressDialog.show(context, "Synchronizing...", "Please wait");
        }

        @Override
        protected Void doInBackground(Void... voids) {
            for (String p : filesDelete) {
                try {
                    if (!new File(baseDir, p).delete()) {
                        Log.w("LiveBuild", "File is not deleted :" + p);
                    }
                } catch (Exception e) {
                    Log.w("LiveBuild", "Failed to delete file :" + p, e);
                }
            }

            for (String p : dirsDelete) {
                try {
                    if (!new File(baseDir, p).delete()) {
                        Log.w("LiveBuild", "Directory is not deleted :" + p);
                    }
                } catch (Exception e) {
                    Log.w("LiveBuild", "Failed to delete directory :" + p, e);
                }
            }

            for (String p : dirsCreate) {
                try {
                    if (!new File(baseDir, p).mkdir()) {
                        Log.w("LiveBuild", "Directory is not created :" + p);
                    }
                } catch (Exception e) {
                    Log.w("LiveBuild", "Failed to create directory :" + p, e);
                }
            }

            for (Map.Entry<String, Long> entry : filesUpdate) {
                String p = entry.getKey();
                try {
                    URLConnection connection = getUrl("files/" + URLEncoder.encode(p, "UTF-8").replace("+", "%20"));
                    InputStream is = connection.getInputStream();

                    WriteLiveFile(baseDir, is, p, entry.getValue());

                } catch (Exception e) {
                    Log.w("LiveBuild", "Failed to update file:" + p, e);
                }
            }

            for (Map.Entry<String, String> e : symlinksToCreate.entrySet()) {
                CreateLink(new File(baseDir, e.getKey()), e.getValue());
            }

            return null;
        }

        @Override
        protected void onPostExecute(Void params) {
            sRunning = false;
            mProgress.dismiss();
            LauncherService.sService.relaunch();
        }
    }

}
