package com.boyaa.cocoslib.adsdk;

import java.util.List;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;

import android.util.Log;

public class AdSdkBridge {

    private static final String TAG = AdSdkBridge.class.getSimpleName();

    private static AdSdkPlugin getAdSdkPlugin() {
        if (Cocos2dxActivityWrapper.getContext() != null) {
            List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
                    .getPluginManager().findPluginByClass(AdSdkPlugin.class);
            if (list != null && list.size() > 0) {
                return (AdSdkPlugin) list.get(0);
            } else {
                Log.d(TAG, "FacebookLoginPlugin not found");
            }
        }
        return null;
    }

    public static void setFbAppId(final String fbAppId) {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  setFbAppId begin");
                    plugin.setFbAppId(fbAppId);
                    Log.d(TAG, "plugin setFbAppId  end");
                }
            }, 50);
        }
    }

    public static void reportStart() {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportStart();
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportReg() {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportReg();
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportLogin() {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportLogin();
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportPlay() {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportPlay();
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportPay(final String pay_money,
            final String currencyCode) {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportPay(pay_money, currencyCode);
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportRecall(final String fbid) {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportRecall(fbid);
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportLogout() {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportLogout();
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }

    public static void reportCustom(final String e_custom) {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  reportStart begin");
                    plugin.reportCustom(e_custom);
                    Log.d(TAG, "plugin reportStart  end");
                }
            }, 50);
        }
    }
}
