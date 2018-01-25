package com.tdp.apiGG;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;
import android.webkit.WebView;

import com.tdp.callbackGG.CallbackGGCoinListener;
import com.tdp.callbackGG.CallbackPayMentListener;
import com.tdp.callbackGG.OnConnectAPIListener;
import com.tdp.utilityGG.Utility;
import com.tdp.variableGG.TDPGlobal;

import org.apache.http.util.EncodingUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;

@SuppressLint("NewApi")
public class ApiPayment {

    //************************************************************************

    static String transactionID_wallet;
    static CallbackGGCoinListener callbackGGCoinListener = null;
    static CallbackPayMentListener callbackPayMentListener = null;
    private final String TAG = "<-- ApiPayment -->";
    public SimpleDateFormat sdf_UnixTimeStamp = new SimpleDateFormat("yyyyMMddhhmmss");
    String Pitem_name, Pcurrency, Ppayment_code, Preference_id, Porder, PreferentID, Papp_user_id;
    double Pprice;

    //*****************************************************************************

    Context mContext = null;
    String unixTime = null;
    String resultTF = null;
    String item_name, app_user_id, reference_id, other;
    double charge_amt;
    private ProgressDialog pDialog;
    private ApiFunction apiFunction = null;
    private WebView payment_webview;
    private String tiam_stam_payment = null;
    private String tiam_stam_wallet = null;
    private String transactionID_payment = null;

    //******************************************************************************

    private WebView wallet_webview;

    public ApiPayment(Context context) {
        this.mContext = context;
        this.apiFunction = new ApiFunction(new CallBack(), mContext);


        //this.apiFunction = new ApiFunction(new CallBack2());
    }

    public ApiPayment() {

    }

    public void getresult_payment(String check) {   // this.CheckSS_Close = check ;
        TDPGlobal.CheckChanal = 2;
        apiFunction.getUnixTime();
    }

    public void getresult_GGWallet() {   // this.CheckSS_Close = check ;
        TDPGlobal.CheckChanal = 4;
        apiFunction.getUnixTime();
    }

    public void openPayMent(String tranID_pay) {
        String api = null;
    /*  if(CheckSS != null)
      {
		  api = ApiList.apiPayment_Informationdev;
	  }
	  else
	  {*/
        api = ApiList.apiPayment_Information;
        //  }

        String hashvalue = Utility.md5(TDPGlobal.APP_ID + "|" + tranID_pay + "|" + tiam_stam_payment + "|" + TDPGlobal.SECRET_KEY);
        //String urlMoblicChanging = String.format(ApiList.apiPayment_Information, TDPGlobal.APP_ID, TDPGlobal.SECRET_KEY, Transac, this.referenceID , hashvalue);
        //Log.e(TAG, "urlMoblicChanging : " + urlMoblicChanging);
        String postData = "app_id=" + TDPGlobal.APP_ID + "&transaction_id=" + tranID_pay + "&timestamp=" + tiam_stam_payment + "&hash_value=" + hashvalue;
        Log.d(TAG, "urlPayment : " + postData);
        try {
            java.net.URLEncoder.encode(postData, "utf-8");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        payment_webview.postUrl(api, EncodingUtils.getBytes(postData, "BASE64"));


    }

    public void setParameterPayment(Double price, String item_name, String currency, String payment_code, String order, WebView paymenr_webview, String ss, String referentID, String app_user_id) {

        this.Pprice = price;
        this.Pitem_name = item_name;
        this.Pcurrency = currency;
        this.Ppayment_code = payment_code;
        this.Porder = order;
        this.payment_webview = paymenr_webview;
        //this.CheckSS = ss;
        this.PreferentID = referentID;
        this.Papp_user_id = app_user_id;
        TDPGlobal.CheckChanal = 1;
        apiFunction.getUnixTime();


    }

    public void setParameterWallet(String item_name, double charge_amt, String app_user_id, String reference_id, WebView wallet_webview, String other) {

        this.item_name = item_name;
        this.charge_amt = charge_amt;
        this.app_user_id = app_user_id;
        this.reference_id = reference_id;
        this.wallet_webview = wallet_webview;
        this.other = other;
        TDPGlobal.CheckChanal = 3;
        apiFunction.getUnixTime();

    }

    public void getresult_wallet(String check) {   // this.CheckSS_Close = check ;
        TDPGlobal.CheckChanal = 2;
        apiFunction.getUnixTime();
    }

    public void openwallet(String tranID_GGwallet) {
        String api = null;

        api = ApiList.apiRequestGGCoin;

        String hashvalue = Utility.md5(TDPGlobal.APP_ID + "|" + tranID_GGwallet + "|" + tiam_stam_wallet + "|" + TDPGlobal.SECRET_KEY);
        Log.d(TAG, TDPGlobal.APP_ID + "|" + tranID_GGwallet + "|" + tiam_stam_wallet + "|" + TDPGlobal.SECRET_KEY);
        String postData = "app_id=" + TDPGlobal.APP_ID + "&transaction_id=" + tranID_GGwallet + "&timestamp=" + tiam_stam_wallet + "&hash_value=" + hashvalue.trim();
        Log.d(TAG, "openwallet : " + postData);

        wallet_webview.postUrl(api, EncodingUtils.getBytes(postData, "BASE64"));


    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public void setCallBackPayMent(CallbackPayMentListener callbackPayMentListener) {
        this.callbackPayMentListener = callbackPayMentListener;
    }

    public void setCallBackGGCoin(CallbackGGCoinListener callbackGGCoinListener) {
        this.callbackGGCoinListener = callbackGGCoinListener;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public void getUnixTime(String response) {
        unixTime = apiFunction.getUnixTime(response);

        if (TDPGlobal.CheckChanal == 1) {

            tiam_stam_payment = unixTime;
            apiFunction.getUnixTiamTranIDPayment(Pprice, Pitem_name, Pcurrency, Ppayment_code, Porder, unixTime, PreferentID, Papp_user_id);
        } else if (TDPGlobal.CheckChanal == 2) {
            apiFunction.close_payment(transactionID_payment, unixTime);
        } else if (TDPGlobal.CheckChanal == 3) {
            tiam_stam_wallet = unixTime;
            apiFunction.getUnixTiamTranIDGGCoin(item_name, charge_amt, app_user_id, reference_id, other, unixTime);
        } else if (TDPGlobal.CheckChanal == 4) {
            apiFunction.close_wallet(transactionID_wallet, unixTime);
        }

    }

    public void getResult_PaymentTranID(String respone) {
        Log.d(TAG, "getResult_PaymentTranID : " + respone);

        try {
            JSONObject resultJSON = new JSONObject(respone);
            String getJSON = resultJSON.getString("result");
            //String result = getJSON.getString("result");
            //Log.d("result", result);
            resultTF = getJSON;
            if (getJSON.equalsIgnoreCase("true")) {
                JSONObject Response = resultJSON.getJSONObject("data");
                transactionID_payment = Response.getString("transaction_id").toString();
                openPayMent(transactionID_payment);
            } else {
                Utility.ShowMsg(mContext, respone);
            }
        } catch (JSONException e) {
            Log.d(TAG, e.toString());
            Utility.ShowMsg(mContext, respone);
        }
    }

    public void getResule_close_payment(String respone) {
        String price, currency, timestamp, hash_value;
        try {
            JSONObject resultJSON = new JSONObject(respone);
            String getJSON = resultJSON.getString("result");
            //String result = getJSON.getString("result");
            //Log.d("result", result);
            resultTF = getJSON;
            if (getJSON.equalsIgnoreCase("true")) {
                JSONObject Response = resultJSON.getJSONObject("data");
                transactionID_payment = Response.getString("transaction_id").toString();
                price = Response.getString("price").toString();
                currency = Response.getString("currency").toString();
                timestamp = Response.getString("timestamp").toString();
                hash_value = Response.getString("hash_value").toString();
                double value = Double.parseDouble(price);
                String HashValue = Utility.md5(TDPGlobal.APP_ID + "|" + transactionID_payment + "|" + getJSON + "|" + price + "|" + currency + "|" + TDPGlobal.SECRET_KEY).trim();
                Log.d(TAG, "HaseValue : " + HashValue);
                Log.d(TAG, "get Hase : " + TDPGlobal.APP_ID + "|" + transactionID_payment + "|" + getJSON + "|" + price + "|" + currency + "|" + TDPGlobal.SECRET_KEY);
                if (hash_value.equalsIgnoreCase(HashValue)) {
                    if (callbackPayMentListener != null)
                        callbackPayMentListener.onSuccess(respone);
                    else
                        Log.d(TAG, respone);
                } else {
                    if (callbackPayMentListener != null)
                        callbackPayMentListener.onFail("invalidHasvalue");
                    else
                        Log.d(TAG, "invalidHasvalue");
                }
            } else {
                if (callbackPayMentListener != null)
                    callbackPayMentListener.onFail(respone);
                else
                    Log.d(TAG, respone);
            }

        } catch (JSONException e) {
            Log.d(TAG, e.toString());
            if (callbackPayMentListener != null)
                callbackPayMentListener.onFail(respone);
            else
                Log.d(TAG, respone);
        }

        //String HashValue =  Utility.md5(TDPGlobal.APP_ID+"|"+transactionID+"|"+timestamp+"|"+result+"|"+price+"|"+currency+"|"+TDPGlobal.SECRET_KEY);
        Log.d(TAG, "getResule_close_payment : " + respone);

    }

    public void getReslt_Close_GGWallet(String respone) {
        Log.d(TAG, respone);
        try {
            JSONObject resultJSON = new JSONObject(respone);
            String getJSON = resultJSON.getString("result");
            //String result = getJSON.getString("result");
            //Log.d("result", result);
            resultTF = getJSON;
            if (getJSON.equalsIgnoreCase("true")) {
                JSONObject Response = resultJSON.getJSONObject("data");
                transactionID_wallet = Response.getString("transaction_id").toString();
                String charged_amt = Response.getString("charged_amt").toString();
                String hash_value = Response.getString("hash_value").toString();
                String timestamp = Response.getString("timestamp").toString();
                String HashValue = Utility.md5(TDPGlobal.APP_ID + "|" + transactionID_wallet + "|" + getJSON + "|" + charged_amt + "|" + timestamp + "|" + TDPGlobal.SECRET_KEY).trim();
                //Log.d(TAG, "HaseValue : "+HashValue );
                //Log.d(TAG, "get Hase : "+TDPGlobal.APP_ID+"|"+transactionID_payment+"|"+getJSON+"|"+price+"|"+currency+"|"+TDPGlobal.SECRET_KEY);
                if (hash_value.equalsIgnoreCase(HashValue)) {
                    if (callbackGGCoinListener != null)
                        callbackGGCoinListener.SuccessPaybyGoodGamesCoin(getJSON);
                    else
                        Log.d(TAG, respone);
                } else {
                    if (callbackGGCoinListener != null)
                        callbackGGCoinListener.FailurePaybyGoodGamesCoin("invalidHasvalue");
                    else
                        Log.d(TAG, "invalidHasvalue");
                }
            } else {
                if (callbackGGCoinListener != null)
                    callbackGGCoinListener.FailurePaybyGoodGamesCoin(respone);
                else
                    Log.d(TAG, respone);
            }
        } catch (JSONException e) {
            Log.d(TAG, e.toString());
            if (callbackGGCoinListener != null)
                callbackGGCoinListener.FailurePaybyGoodGamesCoin(respone);
            else
                Log.d(TAG, respone);
        }
    }

    public void getReslt_TranIdGGWallet(String respone) {
        Log.d(TAG, respone);
        try {
            JSONObject resultJSON = new JSONObject(respone);
            String getJSON = resultJSON.getString("result");
            //String result = getJSON.getString("result");
            //Log.d("result", result);
            resultTF = getJSON;
            if (getJSON.equalsIgnoreCase("true")) {
                JSONObject Response = resultJSON.getJSONObject("data");
                transactionID_wallet = Response.getString("transaction_id").toString();
                openwallet(transactionID_wallet);
            }
        } catch (JSONException e) {
            Log.d(TAG, e.toString());
        }
    }

    private class CallBack implements OnConnectAPIListener {
        @Override
        public void onSuccess(int requestCode, String response) {
            if (requestCode == ApiFunction.REQUEST_CODE_GET_UNIXTIME)
                getUnixTime(response);
            else if (requestCode == ApiFunction.REQUEST_TRANID_PAYMENT)
                getResult_PaymentTranID(response);
            else if (requestCode == ApiFunction.REQUEST_CLOSE_PAYMENT)
                getResule_close_payment(response);
            else if (requestCode == ApiFunction.REQUEST_TRANID_GGWALLET)
                getReslt_TranIdGGWallet(response);
            else if (requestCode == ApiFunction.REQUEST_CLOSE_GGCOIN)
                getReslt_Close_GGWallet(response);
        }

        @Override
        public void onFail(int requestCode, String msgError) {
            Log.d(TAG, "onFail : " + msgError);
        }
    }
}
