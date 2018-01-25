package com.boyaa.cocoslib.ggpay;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;




public class GGPayBridge {
	static final String TAG = GGPayBridge.class.getSimpleName();
	
	private static int purchaseCompleteCallbackMethodId = -1;
	
	public GGPayBridge() {
		// TODO Auto-generated constructor stub
	}
	
	
	
	private static GGPayPlugin getGGPayPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(GGPayPlugin.class);
		if (list != null && list.size() > 0) {
			return (GGPayPlugin) list.get(0);
		} else {
			Log.d(TAG, "GGPayPlugin not found");
		}
		return null;
	}
	
	
	public static void setPurchaseCompleteCallback(int methodId) {
		if (purchaseCompleteCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(purchaseCompleteCallbackMethodId);
			purchaseCompleteCallbackMethodId = -1;
		}
		if (methodId != -1) {
			purchaseCompleteCallbackMethodId = methodId;
		}
	}
	
	
	
	public static void setup(final String appid,final String appsec){
		final GGPayPlugin ggpay = getGGPayPlugin();
		if (ggpay != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					ggpay.setup(appid,appsec);
				}
			}, 50);
			
			
		}
	}
	
	
	static void callLuaPurchaseCompleteCallbackMethod(final String result) {
		Log.d(TAG, "callLuaPurchaseCompleteCallbackMethod " + result);
		if (purchaseCompleteCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
							purchaseCompleteCallbackMethodId, result);
				}
			},50);
		}
	}
	
	
	
	/**
	 * 
	 * @param payment_code 渠道标识
	 * @param itemname
	 * @param price
	 * @param Currency	货币单位
	 * @param reference_id 支付中心生成的订单ID
	 * @param userId    
	 * @param order
	 */
	public static void makePurchase(final String payment_code,final String itemname,final float price,final String Currency,final String reference_id,final String userId,final String order){
		final GGPayPlugin ggpay = getGGPayPlugin();
		if (ggpay != null) {
			Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
				@Override
				public void run() {
					ggpay.makePurchase(payment_code, itemname, price, Currency, reference_id, userId, order);
				}
			}, 50);
			
			
		}
	}

}
