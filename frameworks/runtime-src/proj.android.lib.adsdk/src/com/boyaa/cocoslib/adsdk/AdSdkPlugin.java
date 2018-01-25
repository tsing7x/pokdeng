package com.boyaa.cocoslib.adsdk;

import java.util.HashMap;

import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa.admobile.util.BoyaaADUtil;
import com.boyaa.admobile.util.Constant;

public class AdSdkPlugin extends LifecycleObserverAdapter implements IPlugin {

    private static final String TAG = AdSdkPlugin.class.getSimpleName();
    private String pluginId;
    private String fbAppId;

    @Override
    public void initialize() {
        Cocos2dxActivityWrapper.getContext().addObserver(this);
    }

    @Override
    public void setId(String id) {
        pluginId = id;
    }

    public String getId() {
        return pluginId;
    }

    public void setFbAppId(String id) {
        Log.d(TAG, "AdSdkPlugin set fbAppId ");
        fbAppId = id;
    }

    private boolean isFbAppIdNull() {
        if (fbAppId == null || "".equals(fbAppId))
            return true;
        else
            return false;
    }

    public void reportStart() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push start ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_START);
    }

    public void reportReg() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push reg ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_REG);
    }

    public void reportLogin() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push login ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_LOGIN);
    }

    public void reportPlay() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push play ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_PLAY);
    }

    public void reportPay(String pay_money, String currencyCode) {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        paraterMap.put("pay_money", pay_money);
        paraterMap.put("currencyCode", currencyCode);
        Log.d(TAG, "AdSdkPlugin push pay");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_PAY);
    }

    public void reportRecall(String fbid) {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        paraterMap.put(Constant.RECALL_EXTRA, fbid);
        Log.d(TAG, "AdSdkPlugin push recall ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_RECALL);
    }

    public void reportLogout() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push logout ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_LOGOUT);
    }

    public void reportCustom(String e_custom) {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        paraterMap.put("e_custom", e_custom);
        Log.d(TAG, "AdSdkPlugin push custom ");
        BoyaaADUtil.push(Cocos2dxActivityWrapper.getContext(), paraterMap,
                BoyaaADUtil.METHOD_CUSTOM);
    }
}
