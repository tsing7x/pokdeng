package com.boyaa.cocoslib.gcm;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;

import android.app.ActionBar.Tab;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa.cocoslib.gcm.R;
import com.google.android.gcm.GCMRegistrar;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

public class GoogleCloudMessagingPlugin extends LifecycleObserverAdapter implements IPlugin {
	protected final String TAG = getClass().getSimpleName(); 
	protected String id;
	
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
		//doReg(false);
		needReport(activity.getIntent());
	}
	
	@Override
	public void onNewIntent(Activity activity, Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(activity, intent);
		needReport(intent);
	}
	
	
	public void needReport(Intent intent) {

        final String sid = intent.getStringExtra("sid");
        final String log = intent.getStringExtra("log");
        Log.d(TAG,"needReport===sid:" + sid + " log:" + log);
        if (!TextUtils.isEmpty(sid) && !TextUtils.isEmpty(log)) {
            new Thread(new Runnable(){
                @Override
                public void run() {
                    reportData(sid,log);
                }
            }).start();
        }
	}
	
	public void reportData(String sid,String log) {
		Log.d(TAG,"reportData==============");
	    String url = "http://mvlptlpd01.boyaagame.com/androidtl/api/clicktotal.php?sid="+ sid ;
	    
	    // Log.i("url:", url);
	    HttpPost httpRequest =new HttpPost(url);
	    List <NameValuePair> params=new ArrayList<NameValuePair>();
	    params.add(new BasicNameValuePair("log",log));
	    try {
            httpRequest.setEntity(new UrlEncodedFormEntity(params,HTTP.UTF_8));
            HttpResponse response = new DefaultHttpClient().execute(httpRequest);
            
            HttpEntity entity = response.getEntity();  
            Log.d(TAG,"statusLine:" + response.getStatusLine());  
            if (entity != null) {  
            	Log.d(TAG,"Response content length: "  
                        + entity.getContentLength());  
            } 
         
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	
	
	
	public void register() {
		doReg(true);
	}
	
	private  boolean checkPlayServices(){
		Context ctx = Cocos2dxActivityWrapper.getContext().getApplicationContext();
		 int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(ctx);
		    if (resultCode != ConnectionResult.SUCCESS) {
//		        if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
//		            GooglePlayServicesUtil.getErrorDialog(resultCode, this.act,
//		                    PLAY_SERVICES_RESOLUTION_REQUEST).show();
//		        } else {
//		            Log.i(TAG, "This device is not supported.");
//		        }
		        return false;
		    }
		    return true;

	}
	
	private void doReg(boolean callback) {
		Context ctx = Cocos2dxActivityWrapper.getContext().getApplicationContext();
		if(ctx != null && checkPlayServices()) {
			try {
				//GCMRegistrar.checkDevice(ctx);
				//GCMRegistrar.checkManifest(ctx);
				final String regId = GCMRegistrar.getRegistrationId(ctx);
				if (TextUtils.isEmpty(regId)) {
					GCMRegistrar.register(ctx, ctx.getResources().getStringArray(R.array.gcm_sender_ids));
				} else if(callback) {
					GoogleCloudMessagingBridge.callRegisteredCallback("REG", true, regId);
				}
			} catch(Exception e) {
				Log.e(TAG, e.getMessage(), e);
				if (callback) {
					GoogleCloudMessagingBridge.callRegisteredCallback("REG", false, e.getMessage());
				}
			}
		}
	}
	
}
