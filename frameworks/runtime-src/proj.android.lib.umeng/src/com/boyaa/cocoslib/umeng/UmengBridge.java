package com.boyaa.cocoslib.umeng;

import java.util.List;

import android.R.integer;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.umeng.analytics.game.UMGameAgent;

public class UmengBridge {
	static final String TAG = UmengBridge.class.getSimpleName();

	public UmengBridge() {
		// TODO Auto-generated constructor stub
	}

	private static UmengPlugin getUmengPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(UmengPlugin.class);
		if (list != null && list.size() > 0) {
			return (UmengPlugin) list.get(0);
		} else {
			Log.d(TAG, "UmengPlugin not found");
			return null;
		}
	}

	public static void event(final String eventId, final String label) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.event(eventId, label);
			// 	}
			// }, 50);

		}
	}

	public static void eventCustom(final String eventId, final String attributes) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.eventCustom(eventId, attributes);
			// 	}
			// }, 50);

		}
	}

	public static void eventValue(final String eventId,
			final String attributes, final int du) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.eventValue(eventId, attributes, du);
			// 	}
			// }, 50);

		}
	}

	public static void beginEvent(final String eventId) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.beginEvent(eventId);
			// 	}
			// }, 50);

		}
	}

	public static void beginEventWithLabel(final String eventId,
			final String label) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.beginEventWithLabel(eventId, label);
			// 	}
			// }, 50);

		}
	}

	public static void endEvent(final String eventId) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.endEvent(eventId);
			// 	}
			// }, 50);

		}
	}

	public static void endEventWithLabel(final String eventId,
			final String label) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.endEventWithLabel(eventId, label);
			// 	}
			// }, 50);

		}
	}

	public static void buy(final String item, final int number,
			final float price) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {
					umeng.buy(item, number, price);
			// 	}
			// }, 50);

		}
	}

	public static void bonusCoin(final float coin, final int trigger) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.bonusCoin(coin, trigger);
			// 	}
			// }, 50);

		}
	}

	public static void bonusItem(final String item, final int num,
			final float price, final int trigger) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.bonusItem(item, num, price, trigger);
			// 	}
			// }, 50);

		}
	}

	public static void failLevel(final String level) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.failLevel(level);
			// 	}
			// }, 50);

		}
	}

	public static void startLevel(final String level) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.startLevel(level);
			// 	}
			// }, 50);

		}
	}

	public static void finishLevel(final String level) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.finishLevel(level);
			// 	}
			// }, 50);

		}
	}

	public static void use(final String item, final int number,
			final float price) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.use(item, number, price);
			// 	}
			// }, 50);

		}
	}

	public static void payItem(final float money, final String item,
			final int number, final float price, final int source) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.payItem(money, item, number, price, source);
			// 	}
			// }, 50);

		}
	}

	public static void payCoin(final float money, final float coin,
			final int source) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.payCoin(money, coin, source);
			// 	}
			// }, 50);

		}
	}

	public static void reportError(final String error) {
		final UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			// Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

			// 	@Override
			// 	public void run() {

					umeng.reportError(error);
			// 	}
			// }, 50);

		}
	}

	public static String getConfigParams(final String key) {
		UmengPlugin umeng = getUmengPlugin();

		if (umeng != null) {
			return umeng.getConfigParams(key);
		}

		return "";
	}

}
