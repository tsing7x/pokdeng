package com.tdp.GGWallet;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.tdp.apiGG.ApiPayment;
import com.tdp.callbackGG.CallbackGGCoinListener;
import com.tdp.goodgamespayment.framework.R;


public class GGWallet {

    Context mContext = null;
    ApiPayment apiPayment = null;
    CallbackGGCoinListener callbackGGCoinListener = null;

    public GGWallet(Context mContext) {
        this.mContext = mContext;
        apiPayment = new ApiPayment();


    }//item_name,charge_amt,app_user_id,reference_id,,other

    public void payByGoodGamesCoin(String item_name, double charge_amt, String app_user_id, String reference_id, String other) {

        if (charge_amt != 0) {
            Intent sent = new Intent(Intent.ACTION_VIEW, null, mContext, com.tdp.GGWallet.WalletWebView.class);

            sent.putExtra("item_name", item_name);
            sent.putExtra("charge_amt", charge_amt);
            sent.putExtra("app_user_id", app_user_id);
            sent.putExtra("reference_id", reference_id);
            sent.putExtra("other", other);
            if (reference_id != null) {
                sent.putExtra("reference_id", reference_id);// if you not sent reference_id , SDK will gen  reference_id for you.
            }

            //sent.putExtra("Check", ss);
            mContext.startActivity(sent);
            Activity activity = (Activity) mContext;
            activity.overridePendingTransition(R.anim.fadein, R.anim.fadeout);

        } else {
            if (callbackGGCoinListener != null)
                callbackGGCoinListener.FailurePaybyGoodGamesCoin("Failed amount has to be more than zero");
        }
    }

    public void payByGoodGamesCoin(String item_name, String charge_amt, String app_user_id, String reference_id, String other) {
        if (callbackGGCoinListener != null)
            callbackGGCoinListener.FailurePaybyGoodGamesCoin("chargeamt is String");
    }

    public void setCallBackGoodGamesCoin(CallbackGGCoinListener callbackGGCoinListener) {
        this.callbackGGCoinListener = callbackGGCoinListener;
        apiPayment.setCallBackGGCoin(callbackGGCoinListener);
    }
}