package com.boyaa.cocoslib.ggpay;

import android.Manifest.permission;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.tdp.callbackGG.CallbackPayMentListener;
import com.tdp.goodgamespayment.framework.GGPayment;
import com.tdp.session.GGPaymentSession;


public class GGPayPlugin extends LifecycleObserverAdapter implements IPlugin {
	
	static final String TAG = GGPayPlugin.class.getSimpleName();
	protected String id;
	private Activity mActivity;
	
	private GGPayment ggPayment;
	private GGPaymentSession ggPaySession;
	private CallbackPayMentListener paymentCallback ;
	public GGPayPlugin() {
		
	}

	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		this.id = id;
	}
	
	
	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;
	}
	
	
	
	public void setup(String appid,String appSec) {
		ggPaySession = new GGPaymentSession(appid, appSec);
		ggPayment = new GGPayment(this.mActivity);
		setPaymentCallback();
	}
	
	
	
	
	public void setPaymentCallback(){
		paymentCallback = new CallbackPayMentListener() {
			
			@Override
			public void onSuccess(String result) {
				Log.v(TAG, "success:"+result);
				GGPayBridge.callLuaPurchaseCompleteCallbackMethod(result);
			}
			
			@Override
			public void onFail(String msgError) {
				Log.v(TAG, "fail:"+msgError);
				GGPayBridge.callLuaPurchaseCompleteCallbackMethod(msgError);
				
			}
		};
		
		if(ggPayment != null)
		{
			ggPayment.setCallBackPayMent(paymentCallback);
		}
		
	}
	
	
	
	public void makePurchase(String payment_code, String itemname, double price, String Currency, String reference_id, String userId, String order){
		if(userId == null){
			userId = "app_user_id";
		}
		Log.v(TAG, "payment_code:" + payment_code + " itemname:" + itemname + " price:" + price + " currency:" + Currency + " reference_id:" + reference_id + " userid:"+userId + " order:" + order);
		ggPayment.PaymentGateway(payment_code, itemname, price, Currency, reference_id, userId, order);
	}

}
