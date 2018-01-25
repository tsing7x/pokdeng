package com.boyaa.cocoslib.umeng;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.provider.ContactsContract.CommonDataKinds.Event;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.umeng.analytics.AnalyticsConfig;
import com.umeng.analytics.game.UMGameAgent;

public class UmengPlugin extends LifecycleObserverAdapter implements IPlugin {

	protected String id;
	private Activity mActivity;

	private boolean isDebug = false;
	private static final String UMENG_CHANNEL = "GooglePlay";
	private static final String UMENG_APPKEY = "559f7c4667e58eb515001a4b";

	public UmengPlugin() {
		// TODO Auto-generated constructor stub
	}

	public void initUmeng() {
		UMGameAgent.setDebugMode(isDebug);
		AnalyticsConfig.setAppkey(UMENG_APPKEY);
		AnalyticsConfig.setChannel(UMENG_CHANNEL);
		UMGameAgent.init(this.mActivity);
		// UMGameAgent.onError(this.mActivity);
		UMGameAgent.updateOnlineConfig(this.mActivity);
		UMGameAgent.setCatchUncaughtExceptions(true);
//		UMGameAgent.setSessionContinueMillis(60000);
		// HashMap<String, String> map= new HashMap<String, String>();
		// map.

	}

	public void startLevel(final String level) {
		UMGameAgent.startLevel(level);
	}

	public void failLevel(final String level) {
		UMGameAgent.failLevel(level);
	}

	public void finishLevel(final String level) {
		UMGameAgent.finishLevel(level);
	}

	/**
	 * 
	 * @param money
	 *            本次消费金额(非负数)
	 * @param coin
	 *            本次消费的等值虚拟币(非负数)
	 * @param source
	 *            支付渠道, 1 ~ 99 之间的整数， 1-20 已经被预先定义, 21~99 之间需要在网站设置
	 * 
	 *            1 Google Play 2 支付宝 3 网银 4 财付通 5 移动通信 6 联通通信 7 电信通信 8 paypal
	 * 
	 */
	public void payCoin(double money, double coin, int source) {
		UMGameAgent.pay(money, coin, source);

	}

	/**
	 * 
	 * @param money
	 *            本次消费的金额(非负数)
	 * @param item
	 *            购买物品的ID(不能为空)
	 * @param number
	 *            购买物品数量(非负数)
	 * @param price
	 *            每个物品等值虚拟币的价格(非负数)
	 * @param source
	 *            支付渠道
	 */
	public void payItem(double money, String item, int number, double price,
			int source) {
		UMGameAgent.pay(money, item, number, price, source);
	}

	/**
	 * 
	 * @param item
	 *            购买物品的ID
	 * @param number
	 *            购买物品数量
	 * @param price
	 *            购买物品的单价(虚拟币)
	 */
	public void buy(String item, int number, double price) {
		UMGameAgent.buy(item, number, price);
	}

	/**
	 * 
	 * @param item
	 *            消耗的物品ID
	 * @param number
	 *            消耗物品数量
	 * @param price
	 *            物品单价（虚拟币
	 */
	public void use(String item, int number, double price) {
		UMGameAgent.use(item, number, price);
	}

	/**
	 * 
	 * @param coin
	 *            赠送的虚拟币数额
	 * @param trigger
	 *            触发奖励的事件, 取值在 1~10 之间，“1”已经被预先定义为“系统奖励”， 2~10 需要在网站设置含义。
	 */
	public void bonusCoin(double coin, int trigger) {
		UMGameAgent.bonus(coin, trigger);
	}

	/**
	 * 
	 * @param item
	 *            奖励物品ID
	 * @param num
	 *            奖励物品数量
	 * @param price
	 *            物品的虚拟币单价
	 * @param trigger
	 *            触发奖励的事件, 取值在 1~10 之间，“1”已经被预先定义为“系统奖励”， 2~10 需要在网站设置含义
	 */
	public void bonusItem(String item, int num, double price, int trigger) {
		UMGameAgent.bonus(item, num, price, trigger);
	}

	public void event(String eventId, String label) {

		if (label != null) {
			UMGameAgent.onEvent(this.mActivity, eventId, label);
		} else {
			UMGameAgent.onEvent(this.mActivity, eventId);
		}

	}

	public void eventCustom(String eventId, String attributes) {
		try {
			// JSONObject jsonObject = new JSONObject(json)
			// jsonObject.
			HashMap<String, String> map = new HashMap<String, String>();
			UMGameAgent.onEvent(this.mActivity, eventId, map);
		} catch (Exception e) {
			// TODO: handle exception
		}
	}

	public void eventValue(String eventId, String attributes, int du) {

		try {
			HashMap<String, String> map = new HashMap<String, String>();
			map.put("__ct__", String.valueOf(du));
			UMGameAgent.onEvent(this.mActivity, eventId, map);
		} catch (Exception e) {
			// TODO: handle exception
		}

	}

	public void beginEvent(String eventId) {
		UMGameAgent.onEventBegin(this.mActivity, eventId);

	}

	public void beginEventWithLabel(String eventId, String label) {
		UMGameAgent.onEventBegin(this.mActivity, eventId, label);
	}

	public void endEvent(String eventId) {
		UMGameAgent.onEventEnd(this.mActivity, eventId);
	}

	public void endEventWithLabel(String eventId, String label) {
		UMGameAgent.onEventEnd(this.mActivity, eventId, label);

	}

	public void reportError(String error) {
		Log.e("UmengPlugin", error);
		UMGameAgent.reportError(this.mActivity, error);
	}

	public String getConfigParams(String key) {

		String value = UMGameAgent.getConfigParams(this.mActivity, key);
		if (value == null) {
			value = "";
		}
		return value;

	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;

		// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

		// 	@Override
		// 	public void run() {

				initUmeng();
		// 	}
		// }, 50);

	}

	@Override
	public void onPause(final Activity activity) {
		// TODO Auto-generated method stub
		super.onPause(activity);

		Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			@Override
			public void run() {

				UMGameAgent.onPause(activity);
			}
		}, 50);

	}

	@Override
	public void onResume(final Activity activity) {
		// TODO Auto-generated method stub
		super.onResume(activity);

		Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			@Override
			public void run() {
				UMGameAgent.onResume(activity);
			}
		}, 50);

	}

	@Override
	public void initialize() {
		// TODO Auto-generated method stub
		Cocos2dxActivityWrapper.getContext().addObserver(this);

	}

	@Override
	public void setId(String id) {
		// TODO Auto-generated method stub
		this.id = id;
	}

}
