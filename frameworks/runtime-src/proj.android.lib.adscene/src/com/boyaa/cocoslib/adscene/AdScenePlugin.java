package com.boyaa.cocoslib.adscene;

import org.json.JSONException;
import org.json.JSONObject;

import android.R.bool;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa_sdk.ad.Abstractlistener.AdDataListener;
import com.boyaa_sdk.ad.Abstractlistener.AdListener;
import com.boyaa_sdk.ad.Abstractlistener.InitListener;
import com.boyaa_sdk.ad.datamanager.AdDataManagement;
import com.boyaa_sdk.ad.datamanager.AdWindowsManager;
import com.boyaa_sdk.ad.network.request.RequestConfig;

public class AdScenePlugin extends LifecycleObserverAdapter implements IPlugin {
	static final String TAG = AdScenePlugin.class.getSimpleName();
	
	protected String id;
	private Activity mActivity;
	private boolean isSetupComplete = false;
	private boolean isSetuping = false;
	private boolean isSupported = false;
	private int retryLimit = 4;

	public AdScenePlugin() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;
	}
	
	
	private final AdListener adListener = new AdListener() {
		
		@Override
		public void adShowDialog(int state) {
			//广告框状态回调函数state :0 代表无广告不展示1.有广告广告正常显示
			Log.v(TAG, "adShowDialog");
			AdSceneBridge.callLuaAdShowListener(String.valueOf(state));
		}
		
		@Override
		public void adCloseDialog(int type) {
			//关闭按钮的回调函数 
			//type -- 0:点击back键  1:点击弹框上的关闭按钮    2:点击空白区域 
			Log.v(TAG, "adCloseDialog");
			AdSceneBridge.callLuaAdCloseListener(String.valueOf(type));
		}
	};
	
	
	private final AdDataListener loadAdDataListener = new AdDataListener() {
		
		@Override
		public void adDataLoadSuccess(int type) {
			//返回成功广告的类型
			try {
				JSONObject jsObj= new JSONObject();
				jsObj.put("isSuccess", "true");
				jsObj.put("adType", type);
				AdSceneBridge.callLuaLoadAdDataCompleteListener(jsObj.toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
			
		}
		
		@Override
		public void adDataLoadFaile(int type, String mes) {
			//返回加载广告失败的type 和mes
			try {
				JSONObject jsObj= new JSONObject();
				jsObj.put("isSuccess", "false");
				jsObj.put("adType", type);
				jsObj.put("mes", mes);
				AdSceneBridge.callLuaLoadAdDataCompleteListener(jsObj.toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
			
		}
	};
	
	private final InitListener setupFinishedListener = new InitListener() {
		
		@Override
		public void initSuccess() {
			Log.i(TAG, "Setup successful.");
			isSetupComplete = true;
			isSetuping = false;
			isSupported = true;
			try {
				JSONObject jsObj= new JSONObject();
				jsObj.put("isSupported", String.valueOf(isSupported));
				AdSceneBridge.callLuaSteupCompleteListener(jsObj.toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		
		@Override
		public void initFaile(int errorType, String msg) {
			// TODO Auto-generated method stub
			Log.e(TAG, "Problem setting up adScene ");
			if(retryLimit-- > 0) {
				Log.i(TAG, "retry ... limit left " + retryLimit);
				startSetup();
			} else {
				isSetupComplete = true;
				isSetuping = false;
				isSupported = false;
				try {
					JSONObject jsObj= new JSONObject();
					jsObj.put("isSupported", String.valueOf(isSupported));
					jsObj.put("errorType", errorType);
					jsObj.put("msg", msg);
					AdSceneBridge.callLuaSteupCompleteListener(jsObj.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
				
				
			}
		}
	};
	
	private void startSetup() {
		AdDataManagement.getInstance().init(mActivity);
	}

	public void setup(String appId, String appSec, String channelname, String testUrl) {
		Log.v(TAG, "appId:" + appId + " appSec:" + appSec + " channelname:" + channelname + "testUrl :" + testUrl);

		if (testUrl != null && !testUrl.equals("")) {
			RequestConfig.SERVER_BASE = testUrl;
		}

		Log.v(TAG, "RequestConfig.SERVER_BASE :" + RequestConfig.SERVER_BASE);
		
		if(!isSetupComplete){
			if(!isSetuping){
				isSetuping = true;
				retryLimit = 4;
				AdDataManagement.getInstance().setAppId(appId );
				AdDataManagement.getInstance().setAppSec(appSec);
				AdDataManagement.getInstance().setChannelName(channelname );
				AdDataManagement.getInstance().setInitListener(setupFinishedListener);
				startSetup();
			}
		}
		
//		this.setmGoldListener();
	//	AdDataManagement.getInstance().init(mActivity,"981742001430280263","$2Y$10$B2XJP.34BEKYX/IXUTJ7T./YE", "","1115");
	}
	
	
	
	public void loadAdData(final String userId,final boolean isShowAd) {
		Log.v(TAG, "loadAdData-userId:" + userId + " isShowAd:" + String.valueOf(isShowAd));
		AdDataManagement.getInstance().loadAdData(userId,isShowAd,this.mActivity,loadAdDataListener);
	}

	// 插屏广告
	public void showInterstitialAdDialog(final boolean isFloat) {
		AdWindowsManager.getInstance().showInterstitialAdDialog(this.mActivity,isFloat,adListener);
	}
	
	// 激励广告
	public void showRewardDialog(final boolean isFloat) {
		AdWindowsManager.getInstance().showRewardDialog(this.mActivity,isFloat,adListener);
	}
		

	// 添加/移除 悬浮式广告
	public void setShowRecommendBar(final boolean isShow) {
		if (isShow) {
			AdWindowsManager.getInstance().showRecommendBar(this.mActivity);
		} else {
			AdWindowsManager.getInstance().removeRecommendBar(this.mActivity);
		}

	}


	/**
	 * 九宫格广告
	 *  @param isFloat
	 *	isFloat ：true 代表设置广告弹窗为系统弹出，显示在屏幕最上层
	 *	false 代表普通的广告弹窗
	 */
	public void setShowSudokuDialog(boolean isFloat) {
		AdWindowsManager.getInstance().showSudokuDialog(this.mActivity,isFloat,adListener );

	}

	//关闭dialog
	public void cancelDialog(){
		AdWindowsManager.getInstance().cancelDialog();
	}
	
	/**
	 * 设置Dialog 是否可被back 键关闭
	 * @param cancelable
	 * 传入true 代表可被取消。传入false 不可被取消
	 */
	public void setCancelable(final boolean cancelable) {
		AdWindowsManager.getInstance().setCancelable(cancelable);
	}
	

	// 退出游戏相关缓存
	public void destroy() {
		AdDataManagement.getInstance().destroy();
	}

	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		this.id = id;

	}

}
