package com.boyaa.cocoslib.easy2pay;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.android.easy2pay.Easy2Pay;
import com.android.easy2pay.Easy2PayListener;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;

public class Easy2PayPlugin implements IPlugin, Easy2PayListener {
	protected final String TAG = getClass().getSimpleName();
	protected String id;
	protected Map<String,Easy2Pay> e2pMap = new HashMap<String, Easy2Pay>();
	private Set<String> merchantIdSet;
	private String secretKey;
	private int maxPurchaseWaitingTime;
	private boolean isFullScreen;

	@Override
	public void setId(String id) {
		this.id = id;
	}
	
	public Easy2PayPlugin(Set<String> merchantIdSet, String secretKey, int maxPurchaseWaitingTime, boolean isFullScreen) {
		this.merchantIdSet = merchantIdSet;
		this.secretKey = secretKey;
		this.maxPurchaseWaitingTime = maxPurchaseWaitingTime;
		this.isFullScreen = isFullScreen;
	}

	@Override
	public void initialize() {
		LifecycleObserverAdapter observer = new LifecycleObserverAdapter() {
			@Override
			public void onCreate(Activity activity, Bundle savedInstanceState) {
				if(merchantIdSet != null && !merchantIdSet.isEmpty()) {
					Iterator<String> it = merchantIdSet.iterator();
					while(it.hasNext()) {
						String merchantId = it.next();
						Easy2Pay e2p = new Easy2Pay(activity, merchantId, secretKey, maxPurchaseWaitingTime, isFullScreen);
						e2p.setEasy2PayListener(Easy2PayPlugin.this);
						Log.d(TAG, "create Easy2Pay. version -> " + e2p.getVersion() + " merchantId -> " + merchantId);
						e2pMap.put(merchantId, e2p);
					}
				}
			}
			@Override
			public void onDestroy(Activity activity) {
				Iterator<Entry<String, Easy2Pay>> it = e2pMap.entrySet().iterator();
				while(it.hasNext()) {
					Entry<String, Easy2Pay> entry = it.next();
					String merchantId = entry.getKey();
					Easy2Pay e2p = entry.getValue();
					if(e2p != null) {
						e2p.close();
						Log.d(TAG, "Easy2Pay closed " + merchantId);
					}
					it.remove();
				}
			}
			@Override
			public void onPause(Activity activity) {
				Iterator<Entry<String, Easy2Pay>> it = e2pMap.entrySet().iterator();
				while(it.hasNext()) {
					Entry<String, Easy2Pay> entry = it.next();
					String merchantId = entry.getKey();
					Easy2Pay e2p = entry.getValue();
					if(e2p != null) {
						e2p.onActivityPause();
						Log.d(TAG, "Easy2Pay onPause " + merchantId);
					}
				}
			}
			@Override
			public void onResume(Activity activity) {
				Iterator<Entry<String, Easy2Pay>> it = e2pMap.entrySet().iterator();
				while(it.hasNext()) {
					Entry<String, Easy2Pay> entry = it.next();
					String merchantId = entry.getKey();
					Easy2Pay e2p = entry.getValue();
					if(e2p != null) {
						e2p.onActivityResume();
						Log.d(TAG, "Easy2Pay onResume " + merchantId);
					}
				}
			}
		};
		Cocos2dxActivityWrapper.getContext().addObserver(observer);
	}
	
	public void makePurchase(final String ptxId, final String userId, final String merchantId, final String priceId) {
		Easy2Pay e2p = e2pMap.get(merchantId);
		if(e2p != null) {
			e2p.purchase(ptxId, userId, priceId);
		}
	}


	@Override
	public void onError(String ptxId, String userId, String txId, int errCode, String desc) {
		Map<String, String> dataMap = new HashMap<String, String>();
		dataMap.put("type", "ERROR");
		dataMap.put("errCode", String.valueOf(errCode));
		dataMap.put("ptxId", ptxId);
		dataMap.put("userId", userId);
		dataMap.put("txId", txId);
		dataMap.put("desc", desc);
		Easy2PayBridge.callCallback(dataMap);
	}

	@Override
	public void onEvent(String ptxId, String userId, String txId, int eventCode, String desc) {
		Map<String, String> dataMap = new HashMap<String, String>();
		dataMap.put("type", "EVENT");
		dataMap.put("eventCode", String.valueOf(eventCode));
		dataMap.put("ptxId", ptxId);
		dataMap.put("userId", userId);
		dataMap.put("txId", txId);
		dataMap.put("desc", desc);
		Easy2PayBridge.callCallback(dataMap);
	}

	@Override
	public void onPurchaseResult(String ptxId, String userId, String txId, String priceId, int purchaseCode, String desc) {
		Map<String, String> dataMap = new HashMap<String, String>();
		dataMap.put("type", "RESULT");
		dataMap.put("purchaseCode", String.valueOf(purchaseCode));
		dataMap.put("ptxId", ptxId);
		dataMap.put("userId", userId);
		dataMap.put("txId", txId);
		dataMap.put("priceId", priceId);
		dataMap.put("desc", desc);
		Easy2PayBridge.callCallback(dataMap);
	}
}
