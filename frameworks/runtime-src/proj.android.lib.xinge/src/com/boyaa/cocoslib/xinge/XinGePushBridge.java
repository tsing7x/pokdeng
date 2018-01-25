package com.boyaa.cocoslib.xinge;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;

/**
 * The BOOMEGG Inc 
 * Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved. 
 * @author The Mobile Dev Team
 *          Viking<viking@boomegg.com>
 * 2014-10-15
 */
public class XinGePushBridge {
	private static final String TAG = XinGePushBridge.class.getSimpleName();
	private static int registeredCallbackId = -1;
	
	public static void setRegisteredCallback(int methodId) {
		if(registeredCallbackId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(registeredCallbackId);
			registeredCallbackId = -1;
		}
		registeredCallbackId = methodId;
	}
	
	public static void register() {
		Cocos2dxActivityUtil.runOnBGThread(new Runnable() {
			@Override
			public void run() {
				XinGePushPlugin plugin = getXinGePushPlugin();
				if(plugin != null) {
					Log.d(TAG, "register begin");
					plugin.register();
					Log.d(TAG, "register end");
				}
			}
		});
	}
	
	private static XinGePushPlugin getXinGePushPlugin() {
		if(Cocos2dxActivityWrapper.getContext() != null) {
			List<IPlugin> list = Cocos2dxActivityWrapper.getContext().getPluginManager().findPluginByClass(XinGePushPlugin.class);
			if(list != null && list.size() > 0) {
				return (XinGePushPlugin) list.get(0);
			}else {
				Log.d(TAG, "XinGePushPlugin not found");
			}
		}
		return null;
	}
	
	static void callRegisteredCallback(final String eventType, final boolean success, final String detail) {
		Cocos2dxActivityUtil.runOnResumed(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						JSONObject json = new JSONObject();
						try {
							json.put("type", eventType);
							json.put("success", success);
							json.put("detail", detail);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(registeredCallbackId, json.toString());
						} catch (JSONException e) {
							Log.e(TAG, e.getMessage(), e);
						}
					}
				});
			}
		});
	}
	static void callLuaGlobalCallback(final String funcName, final String detail) {
		Cocos2dxActivityUtil.runOnResumed(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(funcName, detail);
					}
				},2000);
			}
		});
	}
}
