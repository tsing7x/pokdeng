package com.tdp.apiGG;

import android.content.Context;
import android.util.Log;

import com.tdp.callbackGG.OnConnectAPIListener;
import com.tdp.utilityGG.ConnectAPI;
import com.tdp.utilityGG.Utility;
import com.tdp.variableGG.TDPGlobal;

import org.json.JSONException;
import org.json.JSONObject;


public class ApiFunction {

    public static final int REQUEST_CODE_GET_UNIXTIME = 1001;
    public static final int REQUEST_TRANID_PAYMENT = 330778474;
    public static final int REQUEST_CLOSE_PAYMENT = 930778474;
    public static final int REQUEST_TRANID_GGWALLET = 911110;
    public static final int REQUEST_CLOSE_GGCOIN = 911110330;
    private final String TAG = "<-- ApiFunction -->";
    Context context = null;
    private OnConnectAPIListener onConnectAPIListener = null;

    public ApiFunction(OnConnectAPIListener onConnectAPIListener, Context context) {
        this.onConnectAPIListener = onConnectAPIListener;
        this.context = context;
    }

    public void getUnixTime() {
        startConnection(ApiList.apiGetUnixTime, null, REQUEST_CODE_GET_UNIXTIME);
    }

    public void getUnixTiamTranIDPayment(Double price, String item_name, String currency, String payment_code, String order, String timestamp, String refID, String app_user_id) {
        String api = null;
        String reference_id1;
        /*if(check != null)
		{
			api = ApiList.apiPaymentTransIDdev ;
		}
		else
		{*/
        api = ApiList.apiPaymentTransID;
        //}
        String device_id = Utility.getDeviceID(context);
        if (refID == null) {
            reference_id1 = Utility.getreferenceID(context);
        } else {
            reference_id1 = refID;
        }
        String HashValue = Utility.md5(TDPGlobal.APP_ID + "|" + price + "|" + currency + "|" + payment_code + "|" + timestamp + "|" + TDPGlobal.SECRET_KEY);

        //Log.d(TAG, "HASVA : "+TDPGlobal.APP_ID+"|"+price+"|"+currency+"|"+payment_code+"|"+timestamp+"|"+TDPGlobal.SECRET_KEY);
        String urlGetPayment_tranID = String.format(api, TDPGlobal.APP_ID, item_name, price, currency, payment_code, device_id, app_user_id, reference_id1, timestamp, order, HashValue);

        Log.e(TAG, "urlGetPayment_tranID : " + urlGetPayment_tranID);

        startConnection(urlGetPayment_tranID, null, REQUEST_TRANID_PAYMENT);
    }

    public void close_payment(String transactionID, String timestamp) {
        String api = null;
		/*if(check != null)
		{
			api = ApiList.apiclose_Payment_Informationdev;
		}
		else
		{*/
        api = ApiList.apiclose_Payment_Information;
        //}
        //String HashValue1 =  Utility.md5(TDPGlobal.APP_ID+"|"+transactionID+"|"+timestamp+"|"+result+"|"+price+"|"+currency+"|"+TDPGlobal.SECRET_KEY);
        String HashValue = Utility.md5(TDPGlobal.APP_ID + "|" + transactionID + "|" + timestamp + "|" + TDPGlobal.SECRET_KEY);

        String urlClosePayMent = String.format(api, TDPGlobal.APP_ID, transactionID, timestamp, HashValue);

        Log.e(TAG, "urlClosePayMent : " + urlClosePayMent);

        startConnection(urlClosePayMent, null, REQUEST_CLOSE_PAYMENT);
    }

    public void close_wallet(String transactionID, String timestamp) {
        String api = null;
		/*if(check != null)
		{
			api = ApiList.apiclose_Payment_Informationdev;
		}
		else
		{*/
        api = ApiList.apiRequestResultGGCoin;
        //}
        //String HashValue1 =  Utility.md5(TDPGlobal.APP_ID+"|"+transactionID+"|"+timestamp+"|"+result+"|"+price+"|"+currency+"|"+TDPGlobal.SECRET_KEY);
        String HashValue = Utility.md5(TDPGlobal.APP_ID + "|" + transactionID + "|" + timestamp + "|" + TDPGlobal.SECRET_KEY);

        String urlClosePayMent = String.format(api, TDPGlobal.APP_ID, transactionID, timestamp, HashValue);

        Log.e(TAG, "urlClosePayMent : " + urlClosePayMent);

        startConnection(urlClosePayMent, null, REQUEST_CLOSE_GGCOIN);
    }


    //*******************************************************************************************//

    public void getUnixTiamTranIDGGCoin(String item_name, double charge_amt, String app_user_id, String reference_id, String other, String timestamp) {
        String api = null;
        String reference_id1;

        api = ApiList.apiGGCoinRequestTransID;

        String device_id = Utility.getDeviceID(context);
        if (reference_id == null) {
            reference_id1 = Utility.getreferenceID(context);
        } else {
            reference_id1 = reference_id;
        }

        String HashValue = Utility.md5(TDPGlobal.APP_ID + "|" + charge_amt + "|" + reference_id1 + "|" + timestamp + "|" + TDPGlobal.SECRET_KEY);

        //Log.d(TAG, "HASVA : "+TDPGlobal.APP_ID+"|"+price+"|"+currency+"|"+payment_code+"|"+timestamp+"|"+TDPGlobal.SECRET_KEY);
        String urlGetGGWallet_tranID = String.format(api, TDPGlobal.APP_ID, item_name, charge_amt, device_id, app_user_id, reference_id1, timestamp, other, HashValue);

        Log.e(TAG, "urlGetGGWallet_tranID : " + urlGetGGWallet_tranID);

        startConnection(urlGetGGWallet_tranID, null, REQUEST_TRANID_GGWALLET);
    }
    ////////////////////////////////////////////////////////////


    private void startConnection(String url, String postData, int requestCode) {
        new ConnectAPI(url, postData, requestCode, onConnectAPIListener, context).startExecute();
    }


    public String getUnixTime(String response) {
        JSONObject jsonObject = null;
        try {
            jsonObject = new JSONObject(response);
            return jsonObject.getString("UNIXTime");
        } catch (JSONException e) {
            Log.d(TAG, e.toString());
            return null;
        }
    }


}
