package com.boyaa.cocoslib.xinge;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.util.Log;

import com.tencent.android.tpush.XGPushBaseReceiver;
import com.tencent.android.tpush.XGPushClickedResult;
import com.tencent.android.tpush.XGPushRegisterResult;
import com.tencent.android.tpush.XGPushShowedResult;
import com.tencent.android.tpush.XGPushTextMessage;

/**
 * 常见的错误码：<br>
 * 0：表示成功<br>
 * 1：系统错误，指针非法，内存错误等 <br>
 * 2：非法参数<br>
 * 其它：内部错误<br>
 * 
 */
public class XinGePushReceiver extends XGPushBaseReceiver {
	private static final String TAG = XinGePushReceiver.class.getSimpleName();
	
	/**
	 * 注册结果
	 * 
	 * @param context
	 *            APP上下文对象
	 * @param errorCode
	 *            错误码，{@link XGPushBaseReceiver#SUCCESS}表示成功，其它表示失败
	 * @param registerMessage
	 *            注册结果返回
	 */
	@Override
	public void onRegisterResult(Context context, int errorCode, XGPushRegisterResult registerMessage) {
		String text = null;
		if (errorCode == XGPushBaseReceiver.SUCCESS) {
			text = registerMessage + "注册成功";
			// 在这里拿token
			String token = registerMessage.getToken();
			XinGePushBridge.callRegisteredCallback("GOT_PUSH_TOKEN", true, token);
		} else {
			text = registerMessage + "注册失败，错误码：" + errorCode;
			XinGePushBridge.callRegisteredCallback("GOT_PUSH_TOKEN", false, text);
		}
		Log.d(TAG, text);
	}

	/**
	 * 反注册结果
	 * 
	 * @param context
	 *            APP上下文对象
	 * @param errorCode
	 *            错误码，{@link XGPushBaseReceiver#SUCCESS}表示成功，其它表示失败
	 */
	@Override
	public void onUnregisterResult(Context context, int errorCode) {
		String text = null;
		if (errorCode == XGPushBaseReceiver.SUCCESS) {
			text = "反注册成功";
		} else {
			text = "反注册失败" + errorCode;
		}
		Log.d(TAG,text);
	}

	/**
	 * 设置标签操作结果
	 * 
	 * @param context
	 *            APP上下文对象
	 * @param errorCode
	 *            错误码，{@link XGPushBaseReceiver#SUCCESS}表示成功，其它表示失败
	 * @tagName 标签名称
	 */
	@Override
	public void onSetTagResult(Context context, int errorCode, String tagName) {
		String text = null;
		if (errorCode == XGPushBaseReceiver.SUCCESS) {
			text = "\"" + tagName + "\"设置成功";
		} else {
			text = "\"" + tagName + "\"设置失败,错误码：" + errorCode;
		}
		Log.d(TAG,text);
	}

	/**
	 * 删除标签操作结果
	 * 
	 * @param context
	 *            APP上下文对象
	 * @param errorCode
	 *            错误码，{@link XGPushBaseReceiver#SUCCESS}表示成功，其它表示失败
	 * @tagName 标签名称
	 */
	@Override
	public void onDeleteTagResult(Context context, int errorCode, String tagName) {
		String text = null;
		if (errorCode == XGPushBaseReceiver.SUCCESS) {
			text = "\"" + tagName + "\"删除成功";
		} else {
			text = "\"" + tagName + "\"删除失败,错误码：" + errorCode;
		}
		Log.d(TAG,text);
	}

	/**
	 * 收到消息<br>
	 * 
	 * @param context
	 *            APP上下文对象
	 * @param message
	 *            收到的消息
	 */
	@Override
	public void onTextMessage(Context context, XGPushTextMessage message) {
		String text = "收到消息:" + message.toString();
		// 获取自定义key-value
		String customContent = message.getCustomContent();
		if (customContent != null && customContent.length() != 0) {
			try {
				JSONObject obj = new JSONObject(customContent);
//				CoreContext.dispatcher.dispatchEvent(EventId.GOT_PUSH_MESSAGE, obj); TODO
			} catch (JSONException e) {
				Log.e(TAG, e.getMessage());
			}
		}
		// APP自主处理消息的过程。。。
		Log.d(TAG,text);
	}

	/**
	 * 通知被打开结果反馈
	 * 
	 * @param context
	 *            APP上下文对象
	 * @param message
	 *            被打开的消息对象
	 */
	@Override
	public void onNotifactionClickedResult(Context context, XGPushClickedResult message) {
		String text = "通知被打开 :" + message;
		// 获取自定义key-value
		String customContent = message.getCustomContent();
		if (customContent != null && customContent.length() != 0) {
			try {
				JSONObject obj = new JSONObject(customContent);
//				CoreContext.dispatcher.dispatchEvent(EventId.PUSH_MESSAGE_CLICKED, obj); TODO
			} catch (JSONException e) {
				Log.e(TAG, e.getMessage());
			}
		}
		// APP自主处理的过程。。。
		Log.d(TAG,text);
	}

	@Override
	public void onNotifactionShowedResult(Context context, XGPushShowedResult notifiShowedRlt) {
		String text = "已展示通知 :" + notifiShowedRlt;
		Log.d(TAG,text);
	}
}
