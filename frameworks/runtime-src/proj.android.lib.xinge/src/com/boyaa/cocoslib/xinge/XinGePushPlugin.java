package com.boyaa.cocoslib.xinge;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.tencent.android.tpush.XGIOperateCallback;
import com.tencent.android.tpush.XGPushClickedResult;
import com.tencent.android.tpush.XGPushConfig;
import com.tencent.android.tpush.XGPushManager;

/**
 * The BOOMEGG Inc 
 * Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved. 
 * @author The Mobile Dev Team
 *          Viking<viking@boomegg.com>
 * 2014-10-15
 */
public class XinGePushPlugin extends LifecycleObserverAdapter implements IPlugin {
	protected static final String TAG = XinGePushPlugin.class.getSimpleName();
	protected String id;

	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
		
		XGPushConfig.enableDebug(Cocos2dxActivityWrapper.getContext(), false);
		setTags(Cocos2dxActivityWrapper.getContext());
		XGPushManager.registerPush(Cocos2dxActivityWrapper.getContext(), new XGIOperateCallback() {
			@Override
			public void onSuccess(Object data, int flag) {
				Log.d(TAG, "token:" + data);
			}
			@Override
			public void onFail(Object data, int errCode, String msg) {
				Log.e(TAG, "注册失败，错误码：" + errCode + ",错误信息：" + msg);
			}
		});
	}

	@Override
	public void setId(String id) {
		this.id = id;
	}

	@Override
	public void onStart(Activity activity) {
		super.onStart(activity);
		XGPushClickedResult click = XGPushManager.onActivityStarted(activity);
		if (click != null) { // 判断是否来自信鸽的打开方式
			Log.d(TAG, "通知被点击:" + click.toString());
			// String title = click.getTitle(); // 标题
			// String content = click.getContext(); // 正文
			String customContent = click.getCustomContent();
			// 获取自定义key-value
			if (customContent != null && customContent.length() != 0) {
				XinGePushBridge.callLuaGlobalCallback("g_msg_queue_push_json", customContent);
				/*
				try {
					//JSONObject json = new JSONObject(customContent);
					//CoreContext.dispatcher.dispatchEvent(EventId.PUSH_MESSAGE_ENTERED, json);TODO
				} catch (JSONException e) {
					Log.e(TAG, e.getMessage());
				}
				*/
			}
		}
	}

	@Override
	public void onStop(Activity activity) {
		super.onStop(activity);
		XGPushManager.onActivityStoped(activity);
	}
	
	private void setTags(Context ctx) {
		Object umengChannelId = null;
		PackageManager packageManager = ctx.getPackageManager();
		ApplicationInfo applicationInfo;
		try {
			applicationInfo = packageManager.getApplicationInfo(ctx.getPackageName(), 128);
			if (applicationInfo != null && applicationInfo.metaData != null) {
				umengChannelId = applicationInfo.metaData.get("UMENG_CHANNEL");
			}
		} catch (NameNotFoundException e) {
			Log.e(TAG, e.getMessage());
		}
		String name;
		if(umengChannelId != null) {
			name = procTagName(String.valueOf(umengChannelId));
			if(!TextUtils.isEmpty(name)) {
				XGPushManager.setTag(ctx, name);
			}
		}
	}
	
	private String procTagName(Object nameObj) {
		String name = null;
		if(nameObj != null) {
			if(nameObj instanceof String) {
				name = (String) nameObj;
			} else {
				name = String.valueOf(nameObj);
			}
		}
		if(TextUtils.isEmpty(name)) {
			return "";
		} else {
			return name.trim();
		}
	}
	
	public void register() {
		String token = XGPushConfig.getToken(Cocos2dxActivityWrapper.getContext());
		if(!TextUtils.isEmpty(token)) {
			XinGePushBridge.callRegisteredCallback("GOT_PUSH_TOKEN", true, token);
		}
	}
}
