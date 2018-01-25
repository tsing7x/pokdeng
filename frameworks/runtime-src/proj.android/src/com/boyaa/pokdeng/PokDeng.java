package com.boyaa.pokdeng;

import java.util.HashSet;
import java.util.Set;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.Bundle;
import android.util.Log;

// import com.boyaa.cocoslib.adscene.AdScenePlugin;
import com.boyaa.cocoslib.adsdk.AdSdkPlugin;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.PluginManager;
import com.boyaa.cocoslib.easy2payapi.Easy2PayApiPlugin;
//import com.boyaa.cocoslib.easy2pay.Easy2PayPlugin;
import com.boyaa.cocoslib.facebook.FacebookPlugin;
import com.boyaa.cocoslib.gcm.GoogleCloudMessagingPlugin;
import com.boyaa.cocoslib.ggpay.GGPayPlugin;
import com.boyaa.cocoslib.iab.InAppBillingPlugin;
import com.boyaa.cocoslib.xinge.XinGePushPlugin;
import com.boyaa.cocoslib.bluepay.BluePayPlugin;
import com.boyaa.cocoslib.byactivity.ByActivityPlugin;
import com.umeng.analytics.mobclick.game.MobClickCppHelper;

public class PokDeng extends Cocos2dxActivityWrapper {
	
	public static Context STATIC_REF = null;
	
	public static Cocos2dxActivityWrapper getContext() {
        return (Cocos2dxActivityWrapper)STATIC_REF;
    }
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        STATIC_REF = this;
        
        // Log.d("PokDeng", "start MobClickCppHelper.init!");
        Context ctx = Cocos2dxActivityWrapper.getContext();
        String appKey = null;
        String channelId = null;
        
        if (ctx != null) {
        	try {
				ApplicationInfo appInfo = ctx.getPackageManager().getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
				channelId = appInfo.metaData.getString("BM_CHANNEL_ID");
				appKey = appInfo.metaData.getString("BM_DEVICE_ID");
				
				if((channelId != null) && (appKey != null)) {
					channelId = channelId.trim();
					appKey = appKey.trim();
					
					MobClickCppHelper.init(this, appKey, channelId);
				}
			} catch(Exception e) {
				Log.e("PokDeng", e.getMessage(), e);
			}
		}
        
//        MobClickCppHelper.init(this, "58afdc65717c192f2e001a37", "GooglePlay");
        
        addShortcutIfNeeded(R.string.app_name, R.drawable.icon);
        
        setVolumeControlStream(AudioManager.STREAM_MUSIC);
    }
	
	@Override
	 public void onPause() {
		 super.onPause();
		 
		 MobClickCppHelper.onPause(this);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		
		MobClickCppHelper.onResume(this);
		
//		Log.v("NineKe", "mSystemUiVisibility =zzzzzzzzz");
	}
	
	@Override
	protected void onSetupPlugins(PluginManager pluginManager) {
		pluginManager.addPlugin("IN_APP_BILLING", new InAppBillingPlugin("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAljEdxzi2Ftu7FwVkjSllSTXcsx58WGv1mbt8Ts/xY1VLDmBUwSgOago2KHFtBOA2+9TfxbkKpSQzUV42kpCu0J3qNhNgpFy9SnUXaihGJt9YhVhwKMRHX6WGYL4h0+V4x7CHvjGB4zUyLpHRMtSBJp+gE/th7+j80eBmlOtYs/vabMritMLAks4qjxKQTCuBWLwdISfmAVucKLOiE0nxp3E5OaB2JDFJmEupvDA1O9k9k0qsyRWcTFACTebuvoFNmz2M3PAUwmG3uBlECi2PaXVR+DMQpqFJqmgCoAAMyJICJpEEpiMMd3+C01nM35CcNvP6LM9SdBH5Xa+Ki6lVMQIDAQAB", true));
		pluginManager.addPlugin("FACEBOOK", new FacebookPlugin());
		pluginManager.addPlugin("GOOGLE_CLOUD_MESSAGING", new GoogleCloudMessagingPlugin());
		pluginManager.addPlugin("XINGE_PUSH", new XinGePushPlugin());
		
//		Set<String> merchantIdSet = new HashSet<String>();
//		merchantIdSet.add("4056");
//		merchantIdSet.add("4057");
//		pluginManager.addPlugin("EASY_2_PAY", new Easy2PayPlugin(merchantIdSet, "51afe62ef5d04499265ca7ab7a29fb91", 60, true));
		pluginManager.addPlugin("EASY_2_PAY_API", new Easy2PayApiPlugin());
		
		pluginManager.addPlugin("ADSDK", new AdSdkPlugin());
		pluginManager.addPlugin("BluePay",new BluePayPlugin());
		// pluginManager.addPlugin("AdSceneSDK",new AdScenePlugin());
		pluginManager.addPlugin("GGPay", new GGPayPlugin());
		pluginManager.addPlugin("ByActivity", new ByActivityPlugin());
	}
}
