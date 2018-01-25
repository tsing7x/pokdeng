package com.tdp.goodgamespayment.framework;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.tdp.apiGG.ApiPayment;
import com.tdp.callbackGG.CallbackPayMentListener;


public class GGPayment {

    Context mContext = null;
    ApiPayment apiPayment = null;

    public GGPayment(Context mContext) {
        this.mContext = mContext;
        apiPayment = new ApiPayment();
    }

    public void PaymentGateway(String payment_code, String itemname, Double price, String Currency, String reference_id, String app_user_id, String order) {
        Intent sent = new Intent(Intent.ACTION_VIEW, null, mContext, com.tdp.goodgamespayment.framework.PaymentChanal.class);
        sent.putExtra("item_name", itemname);
        sent.putExtra("price", price);
        sent.putExtra("currency", Currency);
        sent.putExtra("payment_code", payment_code);
        sent.putExtra("app_user_id", app_user_id);
        if (reference_id != null) {
            sent.putExtra("reference_id", reference_id);// if you not sent reference_id , SDK will gen  reference_id for you.
        }
        sent.putExtra("order", order);
        //sent.putExtra("Check", ss);
        mContext.startActivity(sent);
        Activity activity = (Activity) mContext;
        activity.overridePendingTransition(R.anim.fadein, R.anim.fadeout);
    }


    public void setCallBackPayMent(CallbackPayMentListener callbackPayMentListener) {
        apiPayment.setCallBackPayMent(callbackPayMentListener);
    }


}