package com.boyaa.cocoslib.gcm;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONObject;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.media.AudioManager;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Vibrator;
import android.support.v4.app.NotificationCompat;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;

import com.boyaa.cocoslib.gcm.R;
import com.google.android.gcm.GCMBaseIntentService;

/**
 * 处理收到的消息
 */
public class GcmIntentService extends GCMBaseIntentService {
	protected String TAG = getClass().getSimpleName();
	
	public GcmIntentService() {
	}
	
	@Override
	protected String[] getSenderIds(Context context) {
		return context.getResources().getStringArray(R.array.gcm_sender_ids);
	}
	
	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onMessage(android.content.Context, android.content.Intent)
	 */
	@Override
	protected void onMessage(Context context, Intent intent) {
		Log.d(TAG, "intent:" + intent);
		if(intent == null || intent.getExtras().isEmpty()){
			return;
		}
		
		Context app = context.getApplicationContext();
		ApplicationInfo appInfo = app.getApplicationInfo();
		
		String parameters = intent.getStringExtra("parameters");
		String tickerText = intent.getStringExtra("tickerText");
		String contentTitle = intent.getStringExtra("contentTitle");
		String contentText = intent.getStringExtra("contentText");
		int id = intent.getIntExtra("id", 0);
		
		
		Log.d(TAG, "Extras -- tickerText:" + tickerText + " contentTitle: " + contentTitle + " contentText:"+contentText + " parameters:" + parameters);
		


		Bitmap bigIconBitmap = null;
		JSONObject json = null;
		Uri webUri = null;
		try {
			json = new JSONObject(parameters);
			//优先使用服务器返回的图标
			if(json.has("pictureUrl")) {
				String pictureUrl = json.getString("pictureUrl");
				if((pictureUrl.startsWith("http://")) || (pictureUrl.startsWith("https://"))){
					URL url = new URL(pictureUrl);
					HttpURLConnection connection = (HttpURLConnection) url.openConnection();
					connection.setDoInput(true);
					connection.connect();
					InputStream input = connection.getInputStream();
					Bitmap retBitmap = BitmapFactory.decodeStream(input);
					bigIconBitmap = Bitmap.createScaledBitmap(retBitmap, 100, 100, true);
					
				}else {
					Log.i(TAG,"illegal pictureUrl");
				}
				
			}
			
			if(json.has("webUrl")){
				String webUrlStr = json.getString("webUrl");
				if(webUrlStr != null && !webUrlStr.equals("")){
					if((webUrlStr.startsWith("http://")) || (webUrlStr.startsWith("https://"))){
						try {
							webUri = Uri.parse(webUrlStr);
							
						} catch (Exception e) {
							
						}
						
					}
					else {
						Log.i(TAG,"illegal webUrl");
					}
					
				}
			}
			
		} catch(Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}
		if(bigIconBitmap == null) {
			//服务器没返回图标，则使用应用图标
			Options options = new BitmapFactory.Options();
			options.inDensity = DisplayMetrics.DENSITY_HIGH;
			options.inTargetDensity = DisplayMetrics.DENSITY_HIGH;
			options.outWidth = 100;
			options.outHeight = 100;
			bigIconBitmap = BitmapFactory.decodeResource(getResources(), appInfo.icon, options);
		}
		if(TextUtils.isEmpty(contentTitle)) {
			contentTitle = getString(appInfo.labelRes);
		}
		if(TextUtils.isEmpty(tickerText)) {
			tickerText = contentText;
		}
		
		Intent notificationIntent = null;
		if(webUri != null){
			notificationIntent = new Intent(Intent.ACTION_VIEW, webUri);
			notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		}else {
			notificationIntent = app.getPackageManager().getLaunchIntentForPackage(app.getPackageName());
		}
		
		boolean needReport = false;
		String sid = intent.getStringExtra("sid");
		String log = intent.getStringExtra("log");

		Log.d(TAG,"sid:" + sid + " log:" + log);
		if (!TextUtils.isEmpty(sid) && !TextUtils.isEmpty(log)) {
		    needReport = true;
		}
		
		if(needReport && webUri == null){
			notificationIntent.putExtra("sid", sid);
	        notificationIntent.putExtra("log", log);
		}
		Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
		long when = System.currentTimeMillis();
		
		PendingIntent contentIntent = PendingIntent.getActivity(context, 0, notificationIntent, 0);
		
		Notification notification = new NotificationCompat.Builder(context)
			.setSmallIcon(R.drawable.ic_stat_gcm)
			.setLargeIcon(bigIconBitmap)
			.setTicker(tickerText)
			.setWhen(when)
			.setAutoCancel(true)
			.setContentTitle(contentTitle)
			.setContentText(contentText)
			.setSound(soundUri, AudioManager.STREAM_NOTIFICATION)
			.setContentIntent(contentIntent)
			.build();
		Vibrator v = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
		if(v != null) {
			v.vibrate(100);  //vibrate 100 ms
		}
		
		NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.notify(id, notification);
	}

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onError(android.content.Context, java.lang.String)
	 */
	@Override
	protected void onError(Context context, String errorId) {
		Log.e(TAG, "errorId:" + errorId);
		GoogleCloudMessagingBridge.callRegisteredCallback("ERR", false, errorId);
	}

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onRegistered(android.content.Context, java.lang.String)
	 */
	@Override
	protected void onRegistered(Context context, String registrationId) {
		Log.d(TAG, "reg id:" + registrationId);
		GoogleCloudMessagingBridge.callRegisteredCallback("REG", true, registrationId);
	}

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onUnregistered(android.content.Context, java.lang.String)
	 */
	@Override
	protected void onUnregistered(Context context, String registrationId) {
		Log.d(TAG, "reg id:" + registrationId);
		GoogleCloudMessagingBridge.callRegisteredCallback("UNREG", true, registrationId);
	}

}
