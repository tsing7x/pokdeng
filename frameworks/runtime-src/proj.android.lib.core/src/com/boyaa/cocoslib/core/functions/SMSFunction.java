package com.boyaa.cocoslib.core.functions;

import java.util.ArrayList;

import android.content.Intent;
import android.net.Uri;
import android.telephony.SmsManager;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;

public class SMSFunction {

	/** 
     * 调起系统发短信功能 
     * @param phoneNumber 
     * @param message 
     */
	public static void doSendSMSTo(final String smsBody,final String smsto) {
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Uri smsToUri = Uri.parse("smsto:" + (smsto == null?"":smsto));
					Intent intent = new Intent(Intent.ACTION_SENDTO, smsToUri);  
					intent.putExtra("sms_body", smsBody);
					try {
						ctx.startActivity(intent);
					} catch(Exception e) {
						Log.e(SMSFunction.class.getSimpleName(), e.getMessage(), e);
					}
				}
			});
		}
	}
	
	
	/** 
     * 直接调用短信接口发短信 
     * @param phoneNumber 
     * @param message 
     */
	public static void sendSMS(final String smsBody,final String smsto) {
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null){
			SmsManager manager = SmsManager.getDefault();  
	         ArrayList<String> list = manager.divideMessage(smsBody);  
	         for(String text:list){  
	             manager.sendTextMessage(smsto, null, text, null, null);  
	         }
		 
		}
	}
	
	
	
}
