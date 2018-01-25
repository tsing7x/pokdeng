package com.boyaa.cocoslib.adscene;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;

import android.util.Log;


public class AdSceneBridge {
	static final String TAG = AdSceneBridge.class.getSimpleName();
	private static int adShowListener = -1;
	private static int adCloseListener = -1;
	private static int setupCompleteListener = -1;
	private static int loadAdDataListener = -1;

	public AdSceneBridge() {
		
	}
	
	
	private static AdScenePlugin getAdScenePlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(AdScenePlugin.class);
		if (list != null && list.size() > 0) {
			return (AdScenePlugin) list.get(0);
		} else {
			Log.d(TAG, "AdScenePlugin not found");
			return null;
		}
	}
	
	public static void callLuaSteupCompleteListener(final String result) {
		Log.d(TAG, "callLuaSteupCompleteListener " + result);
		if (setupCompleteListener != -1) {

					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									setupCompleteListener,
									result);
						}
					});

		}
	}
	
	
	public static void callLuaLoadAdDataCompleteListener(final String result) {
		Log.d(TAG, "callLuaLoadAdDataCompleteListener " + result);
		if (loadAdDataListener != -1) {

					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									loadAdDataListener,
									result);
						}
					});

		}
	}
	
	public static void callLuaAdCloseListener(final String type) {
		Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.adCloseListener,type);
			}
		}, 50);
	}
	
	public static void callLuaAdShowListener(final String state) {
		Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.adShowListener,state);
			}
		}, 50);
	}
	
	
	
	public static void setSetupCompleteListener(int methodId) {
		if (setupCompleteListener != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(setupCompleteListener);
			setupCompleteListener = -1;
		}
		if (methodId != -1) {
			setupCompleteListener = methodId;
		}
	}
	
	public static void setAdCloseListener(int methodId) {
		if (adCloseListener != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(adCloseListener);
			adCloseListener = -1;
		}
		if (methodId != -1) {
			adCloseListener = methodId;
		}
	}
	
	public static void setAdShowListener(int methodId) {
		if (adShowListener != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(adShowListener);
			adShowListener = -1;
		}
		if (methodId != -1) {
			adShowListener = methodId;
		}
	}
	
	
	
	
	public static void setLoadAdDataListener(int methodId) {
		if (loadAdDataListener != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(loadAdDataListener);
			loadAdDataListener = -1;
		}
		if (methodId != -1) {
			loadAdDataListener = methodId;
		}
	}
	

	
	public static void setup(final String appId,final String appSec,final String channelname, final String testUrl) {
		Log.v(TAG,"setup");
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					adscene.setup(appId, appSec, channelname, testUrl);
				}
			},50);
			
		}
	}
	
	
	
	public static void showInterstitialAdDialog(final boolean isFloat) {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					adscene.showInterstitialAdDialog(isFloat);
				}
			},50);
			
		}
		
	}
	
	
	public static void showRewardDialog(final boolean isFloat) {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					adscene.showRewardDialog(isFloat);
				}
			},50);
			
		}
		
	}
	
	
	public static void setShowRecommendBar(final boolean isShow) {
		Log.v(TAG,"setShowRecommendBar:" + String.valueOf(isShow));
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					
					adscene.setShowRecommendBar(isShow);
				}
			},50);
			
		}
		
	}
	
	public static void setShowSudokuDialog(final boolean isFloat) {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					adscene.setShowSudokuDialog(isFloat);
					
				}
			},50);
			
		}

	}
	

	
	public static void loadAdData(final String userId,final boolean isShowAd){
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
				@Override
				public void run() {
					adscene.loadAdData(userId,isShowAd);
				}
			});
			
			
		}
	}
	
	
	
	public static void cancelDialog() {
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
				@Override
				public void run() {
					adscene.cancelDialog();
				}
			});
			
			
		}
	}
	
	
	public static void setCancelable(final boolean cancelable) {
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
				@Override
				public void run() {
					adscene.setCancelable(cancelable);
				}
			});
			
			
		}
	}
	
	
	
	public static void destroy() {
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
				@Override
				public void run() {
					adscene.destroy();
				}
			});
			
			
		}
	}

}
